resource "tls_private_key" "orch" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.name}"
  public_key = "${tls_private_key.orch.public_key_openssh}"
}
