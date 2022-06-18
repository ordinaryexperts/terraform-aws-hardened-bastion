resource "aws_s3_bucket" "this" {
  bucket = coalesce(var.bucket_name, "${local.bastion_name}-storage")
  tags = merge(var.tags, {
    git_commit           = "3bac8ee07452fb00dead429bcb1e2985d898b483"
    git_file             = "s3.tf"
    git_last_modified_at = "2022-06-17 23:56:58"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "f5a8b800-79e7-4bb2-b13d-cc48f8d0dc3e"
  })
  # checkov:skip=CKV_AWS_18: No need for S3 bucket access logging, since only bastion can read this bucket
  # checkov:skip=CKV_AWS_144: No need for cross region replication since bastion is single-region
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current_user.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    owner {
      id = data.aws_canonical_user_id.current_user.id
    }

  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.enable_bucket_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = coalesce(var.bucket_name, "${local.bastion_name}-access-logs")
  tags = merge(var.tags, {
    git_commit           = "3bac8ee07452fb00dead429bcb1e2985d898b483"
    git_file             = "s3.tf"
    git_last_modified_at = "2022-06-17 23:56:58"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "6bbe14ad-80ca-4fd4-a479-336dbb693cae"
  })
  # checkov:skip=CKV_AWS_18: No need for S3 bucket access logging, since only bastion can read this bucket
  # checkov:skip=CKV_AWS_144: No need for cross region replication since bastion is single-region
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = var.enable_bucket_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

