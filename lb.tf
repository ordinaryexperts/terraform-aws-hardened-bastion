resource "aws_lb" "this" {
  subnets            = var.lb_subnets
  load_balancer_type = "network"
  tags               = var.tags
  # checkov:skip=CKV_AWS_152: No need for cross-zone load balancing when bastion only lives in a single AZ
  # checkov:skip=CKV_AWS_150: We don't want deletion protection enabled on this LB
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
