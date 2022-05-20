locals {
  region       = coalesce(var.region, data.aws_region.current.name)
  bastion_name = "${var.vpc_name}-bastion"
}

data "aws_region" "current" {
}

data "aws_availability_zones" "current" {
}

data "aws_ami" "amazonlinux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*-x86_64-gp2"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh.tmpl")

  vars = {
    aws_region        = local.region
    bucket_name       = aws_s3_bucket.this.bucket
    sync_users_script = data.template_file.sync_users.rendered
  }
}

data "template_file" "sync_users" {
  template = file("${path.module}/sync_users.sh.tmpl")

  vars = {
    aws_region  = local.region
    bucket_name = aws_s3_bucket.this.bucket
  }
}

data "aws_canonical_user_id" "current_user" {}

resource "aws_s3_bucket" "this" {
  bucket = coalesce(var.bucket_name, "${local.bastion_name}-storage")

  tags = var.tags

    # Workaround for issue where live infrastructure never conforms with TF,
    # making TF constantly want to re-grant the same grant.
    lifecycle {
      ignore_changes = [grant]
    }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current_user.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    owner {
      id = data.aws_canonical_user_id.current_user.id
    }

  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.enable_bucket_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_security_group" "this" {
  name_prefix = "${local.bastion_name}-sg-"
  vpc_id      = var.vpc_id
  description = "Bastion security group (only SSH inbound access is allowed)"
  tags        = var.tags

  # Only 22 inbound
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = var.cidr_whitelist
  }

  # Anything outbound. Consider restricting
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# exported sg to add to ssh reachable private instances
resource "aws_security_group" "bastion_to_instance_sg" {
  name_prefix = "${local.bastion_name}-to-instance-sg-"
  vpc_id      = var.vpc_id
  tags        = var.tags

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    security_groups = [
      aws_security_group.this.id,
    ]
  }

}

data "aws_iam_policy_document" "assume" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "role_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.this.bucket}/public-keys/*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.this.bucket}"]
    effect    = "Allow"
    condition {
      test     = "StringEquals"
      variable = "s3:prefix"
      values   = ["public-keys/"]
    }
  }
}

resource "aws_iam_role" "this" {
  name_prefix = "${local.bastion_name}-role-"
  path        = "/bastion/"
  tags        = var.tags

  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy" "this" {
  name_prefix = "${local.bastion_name}-policy-"
  role        = aws_iam_role.this.id
  policy      = data.aws_iam_policy_document.role_policy.json
}

resource "aws_iam_instance_profile" "this" {
  name_prefix = "${local.bastion_name}-profile-"
  role        = aws_iam_role.this.name
  path        = "/bastion/"
  tags        = var.tags
}

resource "aws_lb" "this" {
  subnets            = var.lb_subnets
  load_balancer_type = "network"
  tags               = var.tags
}

resource "aws_lb_target_group" "this" {
  port                 = 22
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = 0
  tags                 = var.tags

  health_check {
    port     = "traffic-port"
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "ssh" {
  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.this.arn
  port              = 22
  protocol          = "TCP"
  tags              = var.tags
}

data "aws_route53_zone" "nlb" {
  count = var.create_route53_record ? 1 : 0
  name  = var.hosted_zone
}

resource "aws_route53_record" "nlb" {
  count = var.create_route53_record && var.hosted_zone != "" ? 1 : 0

  name    = var.dns_record_name
  zone_id = data.aws_route53_zone.nlb[0].zone_id
  type    = "A"

  alias {
    evaluate_target_health = true
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
  }
}

resource "aws_autoscaling_group" "this" {
  name_prefix          = "${local.bastion_name}-"
  launch_configuration = aws_launch_configuration.this.name
  max_size             = var.max_count
  min_size             = var.min_count
  desired_capacity     = var.desired_count
  health_check_type    = "EC2"

  vpc_zone_identifier = var.asg_subnets

  target_group_arns = [aws_lb_target_group.this.arn]

  termination_policies = ["OldestLaunchConfiguration"]
  force_delete         = true

  tag {
    key                 = "Name"
    value               = aws_launch_configuration.this.name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "this" {
  name_prefix                 = "${local.bastion_name}-"
  image_id                    = data.aws_ami.amazonlinux.id
  instance_type               = var.instance_type
  associate_public_ip_address = var.associate_public_ip_address
  enable_monitoring           = true
  iam_instance_profile        = aws_iam_instance_profile.this.name
  key_name                    = var.key_name

  security_groups = [aws_security_group.this.id]

  user_data = data.template_file.user_data.rendered

  lifecycle {
    create_before_destroy = true

    # If we do not ignore changes, user_data will be updated on every apply,
    # even if nothing has changed.
    ignore_changes = [user_data]
  }
}

# TODO: harden the instances, add route 53 entries
