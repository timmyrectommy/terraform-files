# Configure Iam role

resource "aws_iam_role" "project-cluster" {
  name = "project-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attach policy
resource "aws_iam_role_policy_attachment" "project-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.project-cluster.name
}
# Attach policy
resource "aws_iam_role_policy_attachment" "project-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.project-cluster.name
}
# create Security group
resource "aws_security_group" "project-cluster" {
  name        = "terraform-eks-project-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.cluster-vpc.id


# Add outbound rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-project"
  }
}

# Add rule 1
resource "aws_security_group_rule" "project-cluster-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.project-cluster.id
  to_port           = 443
  type              = "ingress"
}

# Add rule 2
resource "aws_security_group_rule" "project-cluster-ingress-workstation-http" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.project-cluster.id
  to_port           = 80
  type              = "ingress"
}

# Add rule 3
resource "aws_security_group_rule" "project-cluster-ingress-workstation-ssh" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.project-cluster.id
  to_port           = 22
  type              = "ingress"
}


# Create an EKS cluster
resource "aws_eks_cluster" "project" {
  name     = var.cluster_name
  role_arn = aws_iam_role.project-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.project-cluster.id]
    subnet_ids         = aws_subnet.cluster-subnet[*].id
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.project-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.project-cluster-AmazonEKSVPCResourceController,
   ]
 }
