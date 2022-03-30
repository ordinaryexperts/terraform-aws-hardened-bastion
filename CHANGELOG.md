Unreleased
==========

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
* Checkov baseline static analysis.  All issues flagged by Checkov have *not*
  yet been resolved.
* Status badges for validation and static analysis
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
