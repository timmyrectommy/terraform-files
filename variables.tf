variable "cluster_name" {
  default = "eks-project-cluster"
  type    = string
}

data "aws_availability_zones" "available" {
  state = "available"



variable "instance_names" {
       type = list(string)
       default = ["jenkins-server",  "Ansible-control",  "Ansible-worker1", "Ansible-worker2",  "Ansible-worker3"]
}
