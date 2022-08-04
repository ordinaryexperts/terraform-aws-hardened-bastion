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

# FIXME: This template file is unused
#
#data "template_file" "sync_users" {
#  template = file("${path.module}/sync_users.sh.tmpl")
#
#  vars = {
#    aws_region  = local.region
#    bucket_name = aws_s3_bucket.this.bucket
#  }
#}

data "aws_canonical_user_id" "current_user" {}

resource "aws_s3_bucket" "this" {
  bucket = coalesce(var.bucket_name, "${local.bastion_name}-storage")
  tags = merge(var.tags, {
    git_commit           = "6827c936ba5b32b7b0cfe969ee4bd6a673f7a4c8"
    git_file             = "main.tf"
    git_last_modified_at = "2022-08-04 17:45:31"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "408863f0-cf20-4887-9ac9-48bd5c1649ef"
  })
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
  tags = merge(var.tags, {
    git_commit           = "6827c936ba5b32b7b0cfe969ee4bd6a673f7a4c8"
    git_file             = "main.tf"
    git_last_modified_at = "2022-08-04 17:45:31"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "6d18149d-3a88-4b16-bdd3-4ccde8692c8e"
  })

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
  tags = merge(var.tags, {
    git_commit           = "6827c936ba5b32b7b0cfe969ee4bd6a673f7a4c8"
    git_file             = "main.tf"
    git_last_modified_at = "2022-08-04 17:45:31"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "3e507025-ce80-4c21-b7b8-876ffacd460b"
  })

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
  tags = merge(var.tags, {
    git_commit           = "6827c936ba5b32b7b0cfe969ee4bd6a673f7a4c8"
    git_file             = "main.tf"
    git_last_modified_at = "2022-08-04 17:45:31"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "47cd1e1b-652a-4672-b360-e41750626260"
  })

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
  tags = merge(var.tags, {
    git_commit           = "6827c936ba5b32b7b0cfe969ee4bd6a673f7a4c8"
    git_file             = "main.tf"
    git_last_modified_at = "2022-08-04 17:45:31"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "f7f57de9-5b6b-4cbb-99ec-2287a5f64d3b"
  })
}

resource "aws_lb" "this" {
  subnets            = var.lb_subnets
  load_balancer_type = "network"
  tags = merge(var.tags, {
    git_commit           = "6827c936ba5b32b7b0cfe969ee4bd6a673f7a4c8"
    git_file             = "main.tf"
    git_last_modified_at = "2022-08-04 17:45:31"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "caa4540c-dd76-4fd4-bfb4-eebf1799a89f"
  })
}

resource "aws_lb_target_group" "this" {
  port                 = 22
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = 0
  tags = merge(var.tags, {
    git_commit           = "6827c936ba5b32b7b0cfe969ee4bd6a673f7a4c8"
    git_file             = "main.tf"
    git_last_modified_at = "2022-08-04 17:45:31"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "7f8fba85-797d-4893-b7a9-7a3cdd31d9d6"
  })

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
  tags = merge(var.tags, {
    git_commit           = "6827c936ba5b32b7b0cfe969ee4bd6a673f7a4c8"
    git_file             = "main.tf"
    git_last_modified_at = "2022-08-04 17:45:31"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "03a255f1-a47c-45bd-afe4-a072b4a83a4d"
  })
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

  instance_refresh {
    strategy = "Rolling"
    triggers = ["tag"]
  }

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

  user_data = templatefile("${path.module}/user_data.sh.tmpl", {
    aws_region  = local.region
    bucket_name = aws_s3_bucket.this.bucket
    #    sync_users_script = data.template_file.sync_users.rendered
    sudoers = jsonencode(var.sudoers)
  })

  lifecycle {
    create_before_destroy = true
  }
}
