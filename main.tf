locals {
  region       = coalesce(var.region, data.aws_region.current.name)
  bastion_name = "${var.vpc_name}-bastion"
}

data "aws_region" "current" {
}

data "aws_availability_zones" "current" {
}

data "aws_canonical_user_id" "current_user" {}

# FIXME: This template file is unused
#
#data "template_file" "sync_users" {
#  template = file("${path.module}/sync_users.sh.tmpl")
#
#  vars = {
#    aws_region  = local.region
#    bucket_name = aws_s3_bucket.this.bucket
#  }
#}
