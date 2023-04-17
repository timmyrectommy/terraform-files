#Comfigure AWS provider
provider "aws" {
  region = "us-east-2"
}
# create key pair
resource "aws_key_pair" "project-key" {
  key_name   = "project-key"
  public_key = tls_private_key.rsa.public_key_openssh
}
# create private key
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}
# create local file for private key
resource "local_file" "project-key" {
 content = tls_private_key.rsa.private_key_pem
 filename = "project-key"
}

# Create a  VPC
resource "aws_vpc" "project" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "project-vpc"
  }
}

# Create a subnet
resource "aws_subnet" "project" {
  vpc_id     = aws_vpc.project.id
  cidr_block = "10.0.1.0/24"
 map_public_ip_on_launch = true

  # Define tags for the subnet
  tags = {
    Name = "project-subnet"
  }
}

# Create an Internet gateway
resource "aws_internet_gateway" "project" {
  vpc_id = aws_vpc.project.id
  tags = {
    Name = "project-igw"
  }
}

# Create a route table
resource "aws_route_table" "project" {
  vpc_id = aws_vpc.project.id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project.id
  }
  tags = {
    Name = "project-route-table"
  }
}

# Associate the subnet with the route table
resource "aws_route_table_association" "project" {
  subnet_id      = aws_subnet.project.id
  route_table_id = aws_route_table.project.id
}
# create Security-group
resource "aws_security_group" "project" {
  name        = "project"
  vpc_id      = aws_vpc.project.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project"
  }
}
# Add Security-group-rule
resource "aws_security_group_rule" "project-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.project.id
  to_port           = 443
  type              = "ingress"
}


# Add Security-group-rule
resource "aws_security_group_rule" "project-ingress-workstation-ssh" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.project.id
  to_port           = 22
  type              = "ingress"
}

# Create a new EC2 instance
resource "aws_instance" "project" {
  ami           = "ami-0103f211a154d64a6"
  instance_type = "t2.micro"
  key_name      = "project-key"
  subnet_id     = aws_subnet.project.id
 vpc_security_group_ids = [aws_security_group.project.id]
 count =  length(var.instance_names)
  tags = {
   Name = var.instance_names[count.index]
  }
}
