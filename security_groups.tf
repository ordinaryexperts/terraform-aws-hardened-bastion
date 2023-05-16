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
