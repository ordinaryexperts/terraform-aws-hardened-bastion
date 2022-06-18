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
  tags = merge(var.tags, {
    git_commit           = "acc9d461ebaa6b4d5dc5016a3e391ec295dc1f83"
    git_file             = "iam.tf"
    git_last_modified_at = "2022-06-17 23:35:17"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "39800189-9346-4ffd-b180-2cd9820a1669"
  })

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
  tags = merge(var.tags, {
    git_commit           = "acc9d461ebaa6b4d5dc5016a3e391ec295dc1f83"
    git_file             = "iam.tf"
    git_last_modified_at = "2022-06-17 23:35:17"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "5aa1b956-1e5c-4d46-8b42-f50669b9ece8"
  })
}