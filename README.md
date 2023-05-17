terraform-aws-hardened-bastion
==============================

Terraform module to deploy a security-hardened SSH bastion host in AWS


Status
------

[![Terraform Validation](https://github.com/ordinaryexperts/terraform-aws-hardened-bastion/actions/workflows/terraform_validation.yml/badge.svg)](https://github.com/ordinaryexperts/terraform-aws-hardened-bastion/actions/workflows/terraform_validation.yml)
[![Terraform Static Analysis](https://github.com/ordinaryexperts/terraform-aws-hardened-bastion/actions/workflows/terraform_static_analysis.yml/badge.svg)](https://github.com/ordinaryexperts/terraform-aws-hardened-bastion/actions/workflows/terraform_static_analysis.yml)


Installation
------------

This module can be installed from the Terraform registry: [`ordinaryexperts/hardened-bastion/aws`]


```terraform
module "hardened-bastion" {
  source  = "ordinaryexperts/hardened-bastion/aws"
  version = "2.7.0"  # Be sure to use the latest release
  # insert the 6 required variables here
}
```


Developing
----------

We use [Release Please] to automate releases and changelog generation.  PRs
should be merged to `master` using a squash commit, with the commit message in
[Conventional Commits] format.  ([Conventional Commits cheat sheet])



[Conventional Commits cheat sheet]: https://gist.github.com/Zekfad/f51cb06ac76e2457f11c80ed705c95a3
[Conventional Commits]: https://www.conventionalcommits.org/
[Release Please]: https://github.com/googleapis/release-please
[`ordinaryexperts/hardened-bastion/aws`]: https://registry.terraform.io/modules/ordinaryexperts/hardened-bastion/aws/latest

