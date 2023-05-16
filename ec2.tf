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

  root_block_device {
    encrypted = true
  }

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
