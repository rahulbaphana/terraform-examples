provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "spring_boot_ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["spring-boot-ami*"]
  }

  filter {
    name = "is-public"
    values = ["false"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "all" {}

resource "aws_elb" "main_elb" {
  name = "spring-boot-app-elb"
  internal = "false"
  security_groups = ["${aws_security_group.sg_spring_boot_app_tcp.id}","${aws_security_group.sg_spring_boot_elb.id}"]
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  listener {
    instance_port = "9090"
    instance_protocol = "http"
    lb_port = "80"
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 30
    target              = "TCP:9090"
    interval            = 50
  }

  connection_draining = "true"
  connection_draining_timeout = "300"
}

resource "aws_launch_configuration" "launch_config" {
  image_id             = "${data.aws_ami.spring_boot_ami.id}"
  instance_type        = "t2.micro"
  security_groups      = ["${aws_security_group.sg_spring_boot_app_tcp.id}","${aws_security_group.sg_spring_boot_app_ssh.id}"]
  name_prefix          = "spring-app-lauch-config"

  lifecycle            = {
    create_before_destroy = "true"
  }
}


resource "aws_autoscaling_group" "main_asg" {
  name                      = "spring-app-asg-${aws_launch_configuration.launch_config.name}"
  depends_on                = ["aws_launch_configuration.launch_config"]
  availability_zones        = ["${data.aws_availability_zones.all.names}"]
  launch_configuration      = "${aws_launch_configuration.launch_config.id}"
  max_size                  = "3"
  min_size                  = "1"
  desired_capacity          = "2"
  health_check_type         = "ELB"
  default_cooldown          = 300
  termination_policies      = ["OldestInstance", "Default"]
  load_balancers            = ["${aws_elb.main_elb.name}"]

  lifecycle            = {
    create_before_destroy = "true"
  }
}

resource "aws_security_group" "sg_spring_boot_app_tcp" {
    ingress {
      from_port = 9090
      to_port = 9090
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "sg_spring_boot_app_ssh" {
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "sg_spring_boot_elb" {
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

output "public-dns" {
  value = "${aws_elb.main_elb.public-dns.dns_name}"
}
