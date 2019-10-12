data "aws_route53_zone" "dedicated_node" {
  name  = "${var.domain}"
}
resource "aws_route53_record" "dedicated_node" {
  zone_id = "${data.aws_route53_zone.dedicated_node.zone_id}"
  name    = "${var.name}.${var.domain}."
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.dedicated_node.public_ip}"]
}
