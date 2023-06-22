resource "aws_s3_bucket" "this" {
  bucket = coalesce(var.bucket_name, "${local.bastion_name}-storage")
  tags = merge(var.tags, {
    git_commit           = "6827c936ba5b32b7b0cfe969ee4bd6a673f7a4c8"
    git_file             = "main.tf"
    git_last_modified_at = "2022-08-04 17:45:31"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "408863f0-cf20-4887-9ac9-48bd5c1649ef"
  })
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.enable_bucket_versioning ? "Enabled" : "Disabled"
  }
}
