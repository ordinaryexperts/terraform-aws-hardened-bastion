resource "aws_lb" "this" {
  subnets            = var.lb_subnets
  load_balancer_type = "network"
  tags = merge(var.tags, {
    git_commit           = "acc9d461ebaa6b4d5dc5016a3e391ec295dc1f83"
    git_file             = "lb.tf"
    git_last_modified_at = "2022-06-17 23:35:17"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "91bf3a6c-584d-465d-8860-5aafcdeff26d"
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
    git_commit           = "acc9d461ebaa6b4d5dc5016a3e391ec295dc1f83"
    git_file             = "lb.tf"
    git_last_modified_at = "2022-06-17 23:35:17"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "452f9da3-12d8-43e6-ae0f-74617491bc38"
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
    git_commit           = "acc9d461ebaa6b4d5dc5016a3e391ec295dc1f83"
    git_file             = "lb.tf"
    git_last_modified_at = "2022-06-17 23:35:17"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "546a2398-169a-4efd-a33e-267c4f20a31f"
  })
}
