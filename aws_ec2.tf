#----------------------------------------
# EC2インスタンスの作成
#----------------------------------------
resource "aws_instance" "kk_test_server" {
  ami                    = "ami-03f584e50b2d32776" # Amazon Linux 2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.kk_private_subnet.id
  vpc_security_group_ids = [aws_security_group.kk_private_sg.id]
  key_name               = "kk-key" 
  user_data              = <<EOF
#! /bin/bash
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
EOF
  tags = {
    Name = "kk_test_server"
  }
}
#----------------------------------------
# EC2インスタンスの作成(Ansible)
#----------------------------------------
resource "aws_instance" "kk_ansible_server" {
  ami                    = "ami-03f584e50b2d32776" # Amazon Linux 2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.kk_public_subnet.id
  vpc_security_group_ids = [aws_security_group.kk_public_sg.id]
  key_name               = "kk-key" 
  user_data              = <<EOF
#! /bin/bash
sudo amazon-linux-extras enable ansible2
sudo yum install -y ansible
EOF
  tags = {
    Name = "kk_ansible_server"
  }
}
