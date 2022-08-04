resource "aws_lb" "this" {
  subnets            = var.lb_subnets
  load_balancer_type = "network"
  tags = merge(var.tags, {
    git_commit           = "706b4ea96c8f50f753a62e446a719b3476036c0d"
    git_file             = "lb.tf"
    git_last_modified_at = "2022-08-04 16:54:01"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "355aef28-b037-4b90-97b0-e1dad84ea204"
  })

  access_logs {
    bucket  = aws_s3_bucket.logs.bucket
    enabled = true
  }

  # checkov:skip=CKV_AWS_152: No need for cross-zone load balancing when bastion only lives in a single AZ
  # checkov:skip=CKV_AWS_150: We don't want deletion protection enabled on this LB
}

resource "aws_lb_target_group" "this" {
  port                 = 22
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = 0
  tags = merge(var.tags, {
    git_commit           = "706b4ea96c8f50f753a62e446a719b3476036c0d"
    git_file             = "lb.tf"
    git_last_modified_at = "2022-08-04 16:54:01"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "ffaf31ee-1195-466e-a8d8-6a8a70b68f1a"
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
    git_commit           = "706b4ea96c8f50f753a62e446a719b3476036c0d"
    git_file             = "lb.tf"
    git_last_modified_at = "2022-08-04 16:54:01"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "84e84981-d4d0-4d07-b4f9-57d3ad13cbf3"
  })
}
