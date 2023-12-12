variable "environment" {
  description = "Name of the environment"
  type        = string
  default     = "development"
}

variable "instance_ami" {
  description = "AMI to be used in EC2 instances"
  type        = string
  default     = "ami-028c6514ea77d5ac3"
}

variable "instance_type" {
  description = "Instace type to be used in EC2 instances"
  type        = string
  default     = "t4g.micro"
}

variable "instance_name" {
  description = "Value of the Name Tag for the EC2 instance"
  type        = string
  default     = "task3-instance-dev"
}

variable "vpc_cidr" {
  description = "VPC cider to use"
  type = string
  default = "10.0.0.0/16"
}

variable project_name {
  description = "Name of the project, to be used as a prefix for resource names"
  type = string
  default = "task3"
}

variable iam_instance_profile_arn {
  description = "The iam instance profile for the ec2 instances"
  type = string
  default = "arn:aws:iam::930354804502:instance-profile/ecsInstanceRole"
}