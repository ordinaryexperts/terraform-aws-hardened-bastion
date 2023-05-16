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
