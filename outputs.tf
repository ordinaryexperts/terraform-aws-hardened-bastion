output "bucket_name" {
  value = aws_s3_bucket.keys.bucket
}

output "lb_dns" {
  value = aws_lb.this.dns_name
}

output "bastion_dns" {
  value = aws_route53_record.nlb.*.fqdn
}

output "bastion_sg" {
  value = aws_security_group.this.id
}

output "bastion_to_instance_sg" {
  value = aws_security_group.bastion_to_instance_sg.id
}
