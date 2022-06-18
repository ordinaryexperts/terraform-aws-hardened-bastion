resource "aws_kms_key" "this" {
  description         = "Bastion"
  enable_key_rotation = true
}

resource "aws_kms_alias" "this" {
  target_key_id = aws_kms_key.this.id
  name          = "alias/bastion"
}
