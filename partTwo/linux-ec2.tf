############ PUBLIC-101 INSTANCE ############
resource "aws_instance" "linux101" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = "t2.micro"
  tags = {
    Name = "Linux-101"
  }
  subnet_id                   = aws_subnet.public-101.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.FROM101.id, aws_security_group.SSH2.id]
  user_data                   = <<-EOF
    #!/bin/bash
    sudo yum update -y && sudo yum upgrade -y
    sudo route add -net 172.31.102.0 netmask 255.255.255.0 gw ${element(tolist(aws_network_interface.public-101.private_ips), 0)}
  EOF
}

############ PUBLIC-102 INSTANCE ############
resource "aws_instance" "linux102" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = "t2.micro"
  tags = {
    Name = "Linux-102"
  }
  subnet_id                   = aws_subnet.public-102.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.FROM102.id, aws_security_group.SSH2.id]
  user_data                   = <<-EOF
    #!/bin/bash
    sudo yum update -y && sudo yum upgrade -y
    sudo route add -net 172.31.101.0 netmask 255.255.255.0 gw ${element(tolist(aws_network_interface.public-102.private_ips), 0)}    
  EOF
}

############ OUTPUT CONNECTION INFO ############
output "information" {
  value = <<-EOF

    # Change key security and log into Router-103 Instance
    chmod 400 ${aws_key_pair.generated_key.key_name}.pem
    ssh -i ${aws_key_pair.generated_key.key_name}.pem ec2-user@${aws_instance.router103.public_ip}

    #log into Linux-101 Instance
    ssh -i ${aws_key_pair.generated_key.key_name}.pem ec2-user@${aws_instance.linux101.public_ip}

    #log into Linux-102 Instance
    ssh -i ${aws_key_pair.generated_key.key_name}.pem ec2-user@${aws_instance.linux102.public_ip}

  EOF
}
