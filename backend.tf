terraform {
  backend "s3" {
    bucket = "task3-tf-bknd-dev"
    key    = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "task3-tf-locks-dev"
  }
}