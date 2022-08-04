data "aws_route53_zone" "nlb" {
  count = var.create_route53_record ? 1 : 0
  name  = var.hosted_zone
}

resource "aws_route53_record" "nlb" {
  count = var.create_route53_record && var.hosted_zone != "" ? 1 : 0

  name    = var.dns_record_name
  zone_id = data.aws_route53_zone.nlb[0].zone_id
  type    = "A"

  alias {
    evaluate_target_health = true
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
  }
}
