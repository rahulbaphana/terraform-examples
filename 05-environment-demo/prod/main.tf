terraform {
  required_version = "> 0.9.0"

  backend "s3" {
    region  = "us-east-2"
    bucket  = "terraform-lock-bucket"
    key = "prod_terraform_spring_boot_app.tfstate"
    encrypt = "true"
    lock_table = "Spring-Boot-Lock-Table"
  }
}

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

resource "aws_instance" "example_ec2" {
  ami           = "${data.aws_ami.spring_boot_ami.id}"
  instance_type = "m3.medium"
  vpc_security_group_ids = ["${aws_security_group.sg_spring_boot_app_tcp.id}","${aws_security_group.sg_spring_boot_app_ssh.id}"]

  tags {
    Name = "spring_boot_instance"
  }

  key_name = "rahul_key_pair"
}

resource "aws_security_group" "sg_spring_boot_app_tcp" {
    ingress {
      from_port = 9090
      to_port = 9090
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
