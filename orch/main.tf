### PROVIDERS ###
provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "~/.aws/credentials"
}
provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}


### Node Role ###
resource "aws_iam_role" "node" {
  name = "node"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "node" {
  role       = "${aws_iam_role.node.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}


### DNS ###
resource "cloudflare_record" "orch" {
  count  = "${replace(replace(var.cloudflare_token, "/^$/", "0"), "/..+|[^0]/", "1")}"
  domain = "${var.domain}"
  name   = "${var.name}"
  value  = "${aws_eip.orch.public_ip}"
  type   = "A"
  ttl    = "300"
}
data "aws_route53_zone" "orch" {
  count = "${replace(replace(var.cloudflare_token, "/^0?$/", "1"), "/[^1]/", "0")}"
  name  = "${var.domain}"
}
resource "aws_route53_record" "orch" {
  count   = "${replace(replace(var.cloudflare_token, "/^0?$/", "1"), "/[^1]/", "0")}"
  zone_id = "${data.aws_route53_zone.orch.zone_id}"
  name    = "${var.name}.${var.domain}."
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.orch.public_ip}"]
}


### SSH ###
resource "tls_private_key" "orch" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.name}"
  public_key = "${tls_private_key.orch.public_key_openssh}"
}


### FIREWALL ###
resource "aws_security_group" "node" {
  name        = "node"
  description = "node security group"
  tags {
    Name = "node"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "orch" {
  name        = "${var.name}"
  description = "${var.name} security group"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.name}"
  }
}


### SERVER ###
resource "aws_instance" "orch" {
  instance_type               = "${var.instance_type}"
  ami                         = "${data.aws_ami.rancheros.image_id}"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.cloudconfig.rendered}"
  key_name                    = "${aws_key_pair.ssh_key.key_name}"
  security_groups             = ["${aws_security_group.orch.name}"]
  root_block_device           = {
    volume_type = "gp2"
    volume_size = "${var.volume_size}"
  }
  tags {
    Name = "${var.name}"
  }
}
data "aws_ami" "rancheros" {
  most_recent = true
  owners      = ["605812595337"]
  filter {
    name   = "name"
    values = ["rancheros-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
data "template_file" "cloudconfig" {
  template = "${file("cloud-config.yml")}"
  vars {
    docker_version = "${var.docker_version}"
    domain          = "${var.domain}"
    name            = "${var.name}"
    rancher_version = "${var.rancher_version}"
  }
}
resource "aws_eip" "orch" {
  instance = "${aws_instance.orch.id}"
  vpc      = true
  tags {
    Name = "${var.name}"
  }
}
