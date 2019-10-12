resource "aws_instance" "dedicated_node" {
  instance_type               = "${var.dedicated_instance_type}"
  ami                         = "${var.ami}"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.dedicated_cloudconfig.rendered}"
  key_name                    = "${aws_key_pair.ssh_key.key_name}"
  security_groups             = ["${aws_security_group.node.name}"]
  root_block_device  {
    volume_type = "gp2"
    volume_size = "${var.volume_size}"
  }
  tags = {
    Name = "${var.name}"
  }
}

data "template_file" "dedicated_cloudconfig" {
  template = "${file("dedicated-cloud-config.yml")}"
  vars = {
    aws_access_key = "${var.aws_access_key}"
    aws_secret_key = "${var.aws_secret_key}"
    command        = "${var.command}"
    docker_version = "${var.docker_version}"
    region         = "${var.region}"
  }
}

resource "aws_eip" "dedicated_node" {
  instance = "${aws_instance.dedicated_node.id}"
  vpc      = true
  tags = {
    Name = "${var.name}"
  }
}

# resource "aws_launch_configuration" "dedicated_node" {
#   image_id        = "${var.ami}"
#   instance_type   = "${var.dedicated_instance_type}"
#   key_name        = "${aws_key_pair.ssh_key.key_name}"
#   security_groups = ["${aws_security_group.node.name}"]
#   user_data       = "${data.template_file.dedicated_cloudconfig.rendered}"
#   root_block_device {
#     volume_type = "gp2"
#     volume_size = "${var.volume_size}"
#   }
# }

# resource "aws_autoscaling_group" "dedicated_nodes" {
#   depends_on                = ["aws_launch_configuration.dedicated_node"]
#   availability_zones        = ["${var.region}a", "${var.region}b", "${var.region}c"]
#   name                      = "dedicated-${var.name}"
#   max_size                  = "${var.dedicated_desired_capacity + 2}"
#   min_size                  = "${max(var.dedicated_desired_capacity - 2, 1)}"
#   health_check_grace_period = 300
#   health_check_type         = "EC2"
#   desired_capacity          = "${var.dedicated_desired_capacity}"
#   force_delete              = true
#   launch_configuration      = "${aws_launch_configuration.dedicated_node.name}"
#   lifecycle {
#     create_before_destroy = true
#   }
#   tag {
#     key                 = "Name"
#     value               = "dedicated_${aws_launch_configuration.dedicated_node.name}"
#     propagate_at_launch = true
#   }
# }
