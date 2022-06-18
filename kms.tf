resource "aws_kms_key" "this" {
  description         = "Bastion"
  enable_key_rotation = true
  tags = {
    git_commit           = "3bac8ee07452fb00dead429bcb1e2985d898b483"
    git_file             = "kms.tf"
    git_last_modified_at = "2022-06-17 23:56:58"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "ea03af72-b807-4332-b321-d99d5cdfdf40"
  }
}

resource "aws_kms_alias" "this" {
  target_key_id = aws_kms_key.this.id
  name          = "alias/bastion"
}
