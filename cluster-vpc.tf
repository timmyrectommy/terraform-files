provider "aws" {
  region = "us-east-2"
}
resource "aws_vpc" "cluster-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "terraform-eks-project",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  })
}

resource "aws_subnet" "cluster-subnet" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.cluster-vpc.id

  tags = tomap({
    "Name"                                      = "terraform-eks-project",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  })
}

resource "aws_internet_gateway" "cluster-igw" {
  vpc_id = aws_vpc.cluster-vpc.id

  tags = {
    Name = "terraform-eks-project"
  }
}

resource "aws_route_table" "clusterRT" {
  vpc_id = aws_vpc.cluster-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cluster-igw.id
  }
}

resource "aws_route_table_association" "project" {
  count = 2

  subnet_id      = aws_subnet.cluster-subnet[count.index].id
  route_table_id = aws_route_table.clusterRT.id
}
