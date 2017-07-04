provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example_ec2" {
  ami           = "ami-e086a285"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.sg_nginx_tcp.id}","${aws_security_group.sg_nginx_ssh.id}"]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get -y install nginx
              EOF

  tags {
    Name = "simple_instance_1"
  }

  key_name = "${aws_key_pair.mykeypair.key_name}"
}

resource "aws_key_pair" "mykeypair" {
  key_name = "mykeypair"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_security_group" "sg_nginx_tcp" {
    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_nginx_ssh" {
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
}
