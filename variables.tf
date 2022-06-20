variable "region" {
  description = "AWS Region"
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "cidr_whitelist" {
  type        = list(string)
  description = "List of CIDRs allowed to access ssh on the bastion host"
}

variable "bucket_name" {
  description = "Name for the bastion s3 bucket. Optional, defaults to workspace-bastion-storage"
  default     = ""
}

variable "enable_bucket_versioning" {
  description = "Enable bucket versioning on bastion s3 bucket"
  default     = true
}

variable "asg_subnets" {
  type        = list(string)
  description = "List of subnet IDs for the ASG"
}

variable "lb_subnets" {
  type        = list(string)
  description = "List of subnet IDs for the NLB"
}

variable "desired_count" {
  description = "Desired count for the bastion ASG"
  default     = 1
}

variable "max_count" {
  description = "Max count for the bastion ASG"
  default     = 2
}

variable "min_count" {
  description = "Min count for the bastion ASG"
  default     = 1
}

variable "instance_type" {
  description = "Instance type for the bastion host. Default = t2.nano"
  default     = "t3a.micro" # nano is too weak to run ansible role geerlingguy.security
}

variable "associate_public_ip_address" {
  description = "Associate public IP address to bastion host instances"
  default     = false
}

variable "key_name" {
  description = "Bastion host key pair name"
}

variable "create_route53_record" {
  description = "Create an A record in route 53 for the NLB. If true, hosted_zone is required."
  default     = false
}

variable "hosted_zone" {
  description = "Name of the route53 hosted zone to add a bastion record"
  default     = ""
}

variable "dns_record_name" {
  description = "Name for the A record added to the hosted zone"
  default     = "bastion"
}

variable "tags" {
  default = {}
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC this bastion serves"
}

variable "sudoers" {
  type        = list(string)
  description = "Usernames that will be granted passwordless sudo privilege"
  default     = []
}