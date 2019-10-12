data "aws_route53_zone" "orch" {
  name  = "${var.domain}"
}
resource "aws_route53_record" "orch" {
  zone_id = "${data.aws_route53_zone.orch.zone_id}"
  name    = "${var.name}.${var.domain}."
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.orch.public_ip}"]
}
