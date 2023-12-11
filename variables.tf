variable "environment" {
  description = "Name of the environment"
  type        = string
  default     = "development"
}

variable "instance_ami" {
  description = "AMI to be used in EC2 instances"
  type        = string
  default     = "ami-0c9db8d36d76d38ed"
}

variable "instance_type" {
  description = "Instace type to be used in EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Value of the Name Tag for the EC2 instance"
  type        = string
  default     = "task3-instance-dev"
}

