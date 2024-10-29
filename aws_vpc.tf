#----------------------------------------
# VPCの作成
#----------------------------------------
resource "aws_vpc" "kk_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "kk_vpc" # ここでNameタグを指定
  }
}
#----------------------------------------
# パブリックサブネットの作成
#----------------------------------------
resource "aws_subnet" "kk_public_subnet" {
  vpc_id                  = aws_vpc.kk_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "kk_public_subnet"
  }
}
#----------------------------------------
# プライベートサブネットの作成
#----------------------------------------
resource "aws_subnet" "kk_private_subnet" {
  vpc_id                  = aws_vpc.kk_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "kk_private_subnet"
  }
}
#----------------------------------------
# インターネットゲートウェイの作成
#----------------------------------------
resource "aws_internet_gateway" "kk_igw" {
  vpc_id = aws_vpc.kk_vpc.id
  tags = {
    Name = "kk_igw"
  }
}
#----------------------------------------
# ルートテーブルの作成(パブリック)
#----------------------------------------
resource "aws_route_table" "kk_rtb_public" {
  vpc_id = aws_vpc.kk_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kk_igw.id
  }
  tags = {
    Name = "kk_rtb_public"
  }
}
#----------------------------------------
# サブネットにルートテーブルを紐づけ(パブリック)
#----------------------------------------
resource "aws_route_table_association" "kk_rt_assoc_public" {
  subnet_id      = aws_subnet.kk_public_subnet.id
  route_table_id = aws_route_table.kk_rtb_public.id
}
#----------------------------------------
# ルートテーブルの作成(プライベート)
#----------------------------------------
resource "aws_route_table" "kk_rtb_private" {
  vpc_id = aws_vpc.kk_vpc.id
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  tags = {
    Name = "kk_rtb_private"
  }
}
#----------------------------------------
# サブネットにルートテーブルを紐づけ(プライベート)
#----------------------------------------
resource "aws_route_table_association" "kk_rt_assoc_private" {
  subnet_id      = aws_subnet.kk_private_subnet.id
  route_table_id = aws_route_table.kk_rtb_private.id
}
#----------------------------------------
# セキュリティグループ(パブリック)の作成
#----------------------------------------
resource "aws_security_group" "kk_public_sg" {
  name   = "kk-public-sg"
  vpc_id = aws_vpc.kk_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "kk-public-sg"
  }
}
#----------------------------------------
# セキュリティグループ(プライベート)の作成
#----------------------------------------
resource "aws_security_group" "kk_private_sg" {
  name   = "kk-private-sg"
  vpc_id = aws_vpc.kk_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups  = [aws_security_group.kk_public_sg.id]
  }
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups  = [aws_security_group.kk_public_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "kk-private-sg"
  }
}