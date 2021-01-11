############ GET MY IP ############
data "external" "ipify" {
  program = ["curl", "-s", "https://api.ipify.org?format=json"]
}

############ SSH FROM MY IP SECURITY GROUP ############
resource "aws_security_group" "SSH2" {
  name        = "SSH2"
  description = "SSH2 Security Group"
  vpc_id      = aws_default_vpc.default.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["${data.external.ipify.result.ip}/32"]
    description = "SSH From My IP"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############ ROUTER SECURITY GROUPs ############
resource "aws_security_group" "FROM101" {
  name        = "FROM101"
  description = "FROM101 Security Group"
  vpc_id      = aws_default_vpc.default.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Self Referencing"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "FROM102" {
  name        = "FROM102"
  description = "FROM102 Security Group"
  vpc_id      = aws_default_vpc.default.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Self Referencing"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############ AMI ############
data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

############ ROUTER EC2 ############
resource "aws_instance" "router103" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = "t2.small"
  tags = {
    Name = "Router-103"
  }
  subnet_id                   = aws_subnet.public-103.id
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.FROM101.id, aws_security_group.FROM102.id, aws_security_group.SSH2.id]
  user_data                   = <<-EOF
    #!/bin/bash
    sudo yum update -y && sudo yum upgrade -y
    echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf
  EOF
}

resource "aws_network_interface" "public-101" {
  subnet_id         = aws_subnet.public-101.id
  security_groups   = [aws_security_group.FROM101.id]
  source_dest_check = false
  attachment {
    instance     = aws_instance.router103.id
    device_index = 1
  }
}

resource "aws_network_interface" "public-102" {
  subnet_id         = aws_subnet.public-102.id
  security_groups   = [aws_security_group.FROM102.id]
  source_dest_check = false
  attachment {
    instance     = aws_instance.router103.id
    device_index = 2
  }
}
