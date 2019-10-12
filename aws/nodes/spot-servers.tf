module "autospotting" {
  autospotting_regions_enabled = "${var.region}"
  lambda_zipname               = "lambda.zip"
  source                       = "github.com/autospotting/terraform-aws-autospotting?ref=master"
}

resource "aws_launch_configuration" "spot_node" {
  image_id        = "${var.ami}"
  instance_type   = "${var.spot_instance_type}"
  key_name        = "${aws_key_pair.ssh_key.key_name}"
  security_groups = ["${aws_security_group.node.name}"]
  user_data       = "${data.template_file.spot_cloudconfig.rendered}"
  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.volume_size}"
  }
}

resource "aws_autoscaling_group" "spot_nodes" {
  depends_on                = ["aws_launch_configuration.spot_node"]
  availability_zones        = ["${var.region}a", "${var.region}b", "${var.region}c"]
  name                      = "spot-${var.name}"
  max_size                  = "${var.spot_desired_capacity + 2}"
  min_size                  = "${max(var.spot_desired_capacity - 2, 1)}"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = "${var.spot_desired_capacity}"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.spot_node.name}"
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "spot-enabled"
    value               = "true"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "spot_${aws_launch_configuration.spot_node.name}"
    propagate_at_launch = true
  }
}

data "template_file" "spot_cloudconfig" {
  template = "${file("spot-cloud-config.yml")}"
  vars = {
    aws_access_key = "${var.aws_access_key}"
    aws_secret_key = "${var.aws_secret_key}"
    command        = "${var.command}"
    docker_version = "${var.docker_version}"
    region         = "${var.region}"
  }
}
