resource "aws_instance" "orch" {
  instance_type               = "${var.instance_type}"
  ami                         = "${data.aws_ami.rancheros.image_id}"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.cloudconfig.rendered}"
  key_name                    = "${aws_key_pair.ssh_key.key_name}"
  security_groups             = ["${aws_security_group.orch.name}"]
  root_block_device  {
    volume_type = "gp2"
    volume_size = "${var.volume_size}"
  }
  tags = {
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
  vars = {
    docker_version = "${var.docker_version}"
    domain          = "${var.domain}"
    name            = "${var.name}"
    rancher_version = "${var.rancher_version}"
  }
}

resource "aws_eip" "orch" {
  instance = "${aws_instance.orch.id}"
  vpc      = true
  tags = {
    Name = "${var.name}"
  }
}
