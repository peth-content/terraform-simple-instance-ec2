resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Allow full output"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "allow_http"
    },
  )
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "example_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.pub_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  user_data = <<USER_DATA
#!/bin/bash
sudo apt update
sudo apt install -y nginx
sudo ufw allow 'Nginx HTTP'
sudo systemctl start nginx
sudo systemctl enable nginx
USER_DATA

  tags = merge(
    var.tags,
    {
      Name = "Example Instance"
    },
  )
}