resource "aws_security_group" "this" {
  name_prefix = "${local.bastion_name}-sg-"
  vpc_id      = var.vpc_id
  description = "Bastion security group (only SSH inbound access is allowed)"
  tags = merge(var.tags, {
    git_commit           = "706b4ea96c8f50f753a62e446a719b3476036c0d"
    git_file             = "security_groups.tf"
    git_last_modified_at = "2022-08-04 16:54:01"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "999c9b1d-0db5-428b-8152-176317c5bada"
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
    git_commit           = "706b4ea96c8f50f753a62e446a719b3476036c0d"
    git_file             = "security_groups.tf"
    git_last_modified_at = "2022-08-04 16:54:01"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "bff4ae6a-e404-46f1-abc5-23d2fe68b524"
  })

  ingress {
    description = "SSH ingress from bastion to instances"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    security_groups = [
      aws_security_group.this.id,
    ]
  }

  # checkov:skip=CKV_AWS_23: Adding a description requires replacement of the SG, which cannot be done easily because it is used by other modules
  # checkov:skip=CKV2_AWS_5: This SG is meant to be used by other modules
}
