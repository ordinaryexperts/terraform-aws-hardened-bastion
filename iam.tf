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
    git_commit           = "6827c936ba5b32b7b0cfe969ee4bd6a673f7a4c8"
    git_file             = "main.tf"
    git_last_modified_at = "2022-08-04 17:45:31"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "47cd1e1b-652a-4672-b360-e41750626260"
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
    git_commit           = "6827c936ba5b32b7b0cfe969ee4bd6a673f7a4c8"
    git_file             = "main.tf"
    git_last_modified_at = "2022-08-04 17:45:31"
    git_last_modified_by = "jason.mcvetta@gmail.com"
    git_modifiers        = "jason.mcvetta"
    git_org              = "ordinaryexperts"
    git_repo             = "terraform-aws-hardened-bastion"
    yor_trace            = "f7f57de9-5b6b-4cbb-99ec-2287a5f64d3b"
  })
}
