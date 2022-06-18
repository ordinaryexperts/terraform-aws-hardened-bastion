resource "aws_security_group" "this" {
  name_prefix = "${local.bastion_name}-sg-"
  vpc_id      = var.vpc_id
  description = "Bastion security group (only SSH inbound access is allowed)"
  tags = merge(var.tags, {
    git_commit           = "acc9d461ebaa6b4d5dc5016a3e391ec295dc1f83"
    git_file             = "security_groups.tf"
    git_last_modified_at = "2022-06-17 23:35:17"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "937caa27-3356-4daf-8e9a-71770dbbafb2"
  })

  # Only 22 inbound
  ingress {
    description = "SSH access to bastion"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22

    cidr_blocks = var.cidr_whitelist
  }

  # Anything outbound. Consider restricting
  egress {
    description = "Egress from bastion"
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
    git_commit           = "3bac8ee07452fb00dead429bcb1e2985d898b483"
    git_file             = "security_groups.tf"
    git_last_modified_at = "2022-06-17 23:56:58"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "2fabca22-dc3d-48fc-bfa2-732f55296771"
  })
  description = "SSH access from bastion to instances"

  ingress {
    description = "SSH ingress from bastion to instances"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    security_groups = [
      aws_security_group.this.id,
    ]
  }

  # checkov:skip=CKV2_AWS_5: This SG is meant to be used by other modules
}
