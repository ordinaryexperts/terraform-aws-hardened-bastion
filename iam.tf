data "aws_iam_policy_document" "assume" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "role_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.this.bucket}/public-keys/*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.this.bucket}"]
    effect    = "Allow"
    condition {
      test     = "StringEquals"
      variable = "s3:prefix"
      values   = ["public-keys/"]
    }
  }
}

resource "aws_iam_role" "this" {
  name_prefix = "${local.bastion_name}-role-"
  path        = "/bastion/"
  tags        = var.tags

  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy" "this" {
  name_prefix = "${local.bastion_name}-policy-"
  role        = aws_iam_role.this.id
  policy      = data.aws_iam_policy_document.role_policy.json
}

resource "aws_iam_instance_profile" "this" {
  name_prefix = "${local.bastion_name}-profile-"
  role        = aws_iam_role.this.name
  path        = "/bastion/"
  tags        = var.tags
}