locals {
  region       = coalesce(var.region, data.aws_region.current.name)
  bastion_name = "${var.vpc_name}-bastion"
}

data "aws_region" "current" {}

data "aws_availability_zones" "current" {}

data "aws_canonical_user_id" "current_user" {}

data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "main" {}

