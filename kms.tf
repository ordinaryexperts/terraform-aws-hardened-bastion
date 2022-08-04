resource "aws_kms_key" "this" {
  description         = "Bastion"
  enable_key_rotation = true
  tags = {
    git_commit           = "706b4ea96c8f50f753a62e446a719b3476036c0d"
    git_file             = "kms.tf"
    git_last_modified_at = "2022-08-04 16:54:01"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "b9d5b78f-84ba-4007-893a-74c7b0a064c6"
  }
}

resource "aws_kms_alias" "this" {
  target_key_id = aws_kms_key.this.id
  name          = "alias/bastion"
}
