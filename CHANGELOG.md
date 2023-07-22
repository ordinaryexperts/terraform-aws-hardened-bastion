# Changelog

## [2.9.0](https://github.com/ordinaryexperts/terraform-aws-hardened-bastion/compare/v2.8.0...v2.9.0) (2023-07-22)


### Features

* install convenience packages ([#30](https://github.com/ordinaryexperts/terraform-aws-hardened-bastion/issues/30)) ([01b0356](https://github.com/ordinaryexperts/terraform-aws-hardened-bastion/commit/01b0356a122853ebce3602935ade7561be35730a))

## [2.8.0](https://github.com/ordinaryexperts/terraform-aws-hardened-bastion/compare/v2.7.1...v2.8.0) (2023-07-21)


### Features

* install the latest SSM agent ([646fd6e](https://github.com/ordinaryexperts/terraform-aws-hardened-bastion/commit/646fd6efe25a491f75c0abbd1ce8278ec3398d61))

## [2.7.1](https://github.com/ordinaryexperts/terraform-aws-hardened-bastion/compare/v2.7.0...v2.7.1) (2023-06-23)


### Bug Fixes

* remove obsolete S3 bucket ACL resource ([#25](https://github.com/ordinaryexperts/terraform-aws-hardened-bastion/issues/25)) ([304616d](https://github.com/ordinaryexperts/terraform-aws-hardened-bastion/commit/304616d8db6bbf45eb46deea81830c4107474db0))

## [2.7.0](https://github.com/ordinaryexperts/terraform-aws-hardened-bastion/compare/2.6.0...v2.7.0) (2023-05-16)


### Features

* Enable root EBS volume encryption ([#22](https://github.com/ordinaryexperts/terraform-aws-hardened-bastion/issues/22)) ([b5b3135](https://github.com/ordinaryexperts/terraform-aws-hardened-bastion/commit/b5b313535e309e529788c74437a47128d3d38286))

Unreleased
==========

2.6.0
=====

* Use `templatefile()` function instead of `template_file` data source.

2.5.0
=====

* Rolled back to release 2.3.0 - release 2.4.0 was premature.  This release is
  identical to release 2.3.0.

2.3.0
=====

* Bump AWS Provider version to 4.x

2.2.0
=====

* Security hardening with Ansible role `geerlingguy.security`

2.1.0
=====

* Add a Makefile for convenience
* Update syntax for `aws_s3_bucket`
* Remove `lifecycle ignore_changes` workaround for issue where live
  infrastructure never conformed with TF, making TF constantly want to re-grant
  the same grant.  Issue was eliminated after the switch to new syntax.

2.0.0
=====

* Update AWS provider required version to ~> 3.0
* Checkov baseline static analysis.  All issues flagged by Checkov have *not*
  yet been resolved.
* Status badges for validation and static analysis
* Improved naming of autoscaling group and launch configuration, so that ASG is
  not re-created every time `terraform apply` is run.
* `tags` variable allows tagging of bastion
* Ignore changes on launch configuration user_data.  This prevents the launch
  configuration from being updated on every apply, even when nothing has
  changed.
* Lifecycle ignore changes on S3 bucket grant, as workaround for TF wanting
  constantly to re-grant the same grant

1.1.0
=====
* Reduce load balancer target group deregistration delay from 300 seconds to 0 seconds
* Github Action runs automated validation on terraform code

1.0.0
=====
* Syntax updates to 0.13.1
* Deletion of acl argument with the addition of a grant policy to the s3 updload bucket
