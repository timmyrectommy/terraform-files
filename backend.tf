terraform {
  backend "s3" {
    bucket = "t-project-state-bucket"
    key    = " eks-cluster/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "t-project-state-lock"
  }
}
