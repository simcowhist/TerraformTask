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

variable "vpc_cidr" {
  description = "VPC cider to use"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "IP ranges for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "private_subnets" {
  description = "IP ranges for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "database_subnets" {
  description = "IP ranges for database subnets"
  type        = list(string)
  default     = ["10.0.201.0/24"]
}
variable "project_name" {
  description = "Name of the project, to be used as a prefix for resource names"
  type        = string
  default     = "task3"
}

variable "iam_instance_profile_arn" {
  description = "The iam instance profile for the ec2 instances"
  type        = string
  default     = "arn:aws:iam::930354804502:instance-profile/ecsInstanceRole"
}

variable "min_scaling_size" {
  description = "minimum amount of instances for the auto scaling group"
  type        = number
  default     = 0
}

variable "max_scaling_size" {
  description = "maximum amount of instances for the auto scaling group"
  type        = number
  default     = 0
}
variable "desired_capacity" {
  description = "desired instance capcity for the auto scaling group"
  type        = number
  default     = 0
}

variable "db_multi_az" {
  description = "Value to determine if database instance should be across multiple az"
  type        = bool
  default     = true
}

variable "db_manage_master_password" {
  description = "Value to determine if aws should manage the database's master password"
  type        = bool
  default     = true
}