provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "pub_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "my_gw" {
  Vpc_id = aws_vpc.my_vpc.id

  tags = {
     Name = "my_igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route" "routing" {
  route_table_id = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0./0"
  gateway_id = aws_internet_gateway.my_gw.id
}

resource "aws_route_table_association" "mapping" {
  subnet_id = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port = 80
    to_port    = 80
    protocol = "tcp"
   codr_blocks = ["0.0.0.0/0"]
 }
 egress {
    from_port  = 0 
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
 tags = {
   Name = "public_sg"
 }
}

resource "aws_instance" "my_ec2" {
  ami = "ami-"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.pub_subnet.id
  security_groups = aws_security_group.public_sg.id

  tags = {
    Name = "Pub_instance"
  }
}

output "instance_id" {
  value = aws_instance.my_ec2.id
}
