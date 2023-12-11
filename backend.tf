terraform {
  backend "s3" {
    bucket = "task3-tf-bknd-dev"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}