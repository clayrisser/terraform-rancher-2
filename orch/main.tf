provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "~/.aws/credentials"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.name}"
  public_key = "${file(var.pub_key_path)}"
}

data "aws_route53_zone" "public" {
  name = "${var.domain}"
}

resource "aws_route53_record" "public" {
  zone_id = "${data.aws_route53_zone.public.zone_id}"
  name    = "${var.name}.${var.domain}."
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.orch.public_ip}"]
}

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
    name            = "${var.name}"
    domain          = "${var.domain}"
    rancher_version = "${var.rancher_version}"
  }
}

resource "aws_instance" "orch" {
  iam_instance_profile        = "k8s-ec2-route53"
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
