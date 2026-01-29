terraform {
  backend "s3" {
    bucket         = "ben-state-project6"
    key            = "eks-cluster/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ben-devops-locks"          
    encrypt        = true
  }
}