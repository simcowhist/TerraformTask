variable "environment" {
  description = "Name of the environment"
  type        = string
  default     = "development"
}

variable "region" {
  description = "Name of the aws region"
  type        = string
  default     = "us-east-1"
}

variable "instance_ami" {
  description = "AMI to be used in EC2 instances"
  type        = string
  default     = "ami-0c9db8d36d76d38ed"
}

variable "instance_type" {
  description = "Instace type to be used in EC2 instances"
  type        = string
  default     = "t3.large"
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

variable "skip_final_snapshot" {
  description = "Value to determine if final snapshot should be skipped or not."
  type        = bool
  default     = false
}

variable "db_port" {
  description = "Port to be used for communiation with db"
  type        = string
  default     = "3306"
}

variable "alb_internal" {
  description = "Value to determine if the alb is internal or internet facing"
  type        = bool
  default     = false
}

variable "alb_create_security_group" {
  description = "Value to determine if a separate security group should be created for the alb"
  default     = false
  type        = bool
}

variable "create_database_subnet_group" {
  description = "Value to determine if to create a database subnet group"
  default     = true
  type        = bool
}

variable "enable_nat_gateway" {
  description = "Value to determine if to create a nat gateway"
  default     = true
  type        = bool
}

variable "public_security_group_ingress_cidr_blocks" {
  description = "What ingress cidr blocks are allowed to the public security group"
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

variable "public_security_group_ingress_rules" {
  description = "What ingress rules the public security group has"
  default     = ["http-80-tcp"]
  type        = list(string)
}

variable "public_security_group_egress_rules" {
  description = "What egress rules the public security group has"
  default     = ["all-all"]
  type        = list(string)
}

variable "private_security_group_ingress_rules" {
  description = "What ingress rules the private security group has"
  default     = ["http-80-tcp"]
  type        = list(string)
}

variable "private_security_group_egress_cidr_blocks" {
  description = "What cidr blocks is the private security group allowed to access"
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

variable "private_security_group_egress_rules" {
  description = "What egress rules the private security group has"
  default     = ["all-all"]
  type        = list(string)
}

variable "db_security_group_protocol" {
  description = "What protocol the db security group uses"
  default     = "tcp"
  type        = string
}

variable "db_engine" {
  description = "What db to use"
  default     = "mysql"
  type        = string
}

variable "db_major_engine_version" {
  description = "The major version of the db engine"
  default     = "8.0"
  type        = string
}

variable "db_engine_version" {
  description = "The version of the db engine"
  default     = "8.0"
  type        = string
}

variable "db_family" {
  description = "The db family name"
  default     = "8.0mysql"
  type        = string
}

variable "db_instance_type" {
  description = "AWS Instace type of the db"
  default     = "db.r5.large"
  type        = string
}

variable "db_allocated_stroage" {
  description = "Allocated storage of the db in GB"
  default     = 10
  type        = number
}

variable "db_master_user" {
  description = "Name of the master user in the database"
  default     = "admin"
  type        = string
}

variable "webapp_container_name" {
  description = "Name of the container to be run"
  default     = "webapp"
  type        = string
}

variable "webapp_cpu" {
  description = "amount of cpu allocation for webapp container"
  default     = 0
  type        = number
}

variable "webapp_memory_hard_limit" {
  description = "Hard limit memory allocation in MB"
  default     = 512
  type        = number
}

variable "webapp_memory_soft_limit" {
  description = "Soft limit memory allocation in MB"
  default     = 256
  type        = number
}

variable "webapp_image" {
  description = "Image url for the webapp container"
  default     = "930354804502.dkr.ecr.us-east-1.amazonaws.com/simcowhist"
  type        = string
}

variable "webapp_host_port" {
  description = "Port for the host machine to listen on"
  default     = 80
  type        = number
}

variable "webapp_container_port" {
  description = "Port for the container to listen on"
  default     = 80
  type        = number
}

variable "webapp_app_protocol" {
  description = "Protocol for the application"
  default     = "tcp"
  type        = string
}

variable "webapp_protocol" {
  default = "http"
  type    = string
}

variable "webapp_essential" {
  description = "Value to determine if the webapp container is essential"
  type        = bool
  default     = true
}
variable "task_memory" {
  description = "Memory allocation for the task"
  type        = number
  default     = 512
}

variable "task_cpu" {
  description = "Cpu allocation for the task"
  type        = number
  default     = 256
}

variable "webapp_log_driver" {
  default     = "awslogs"
  type        = string
  description = "what log driver to use"
}

variable "webapp_network_mode" {
  default     = "awsvpc"
  type        = string
  description = "Network mode for the webapp containers"
}

variable "webapp_runtime_platform_cpu_architecture" {
  default = "X86_64"
  type    = string
}

variable "webapp_runtime_platform_operating_system_family" {
  default = "LINUX"
  type    = string
}

variable "aws_logs_create_group" {
  default     = true
  type        = bool
  description = "if to create aws log group"
}

variable "aws_logs_stream_prefix" {
  default     = "ecs"
  type        = string
  description = "Prefix for the aws logs stream"
}

variable "task_def_requiers_compatabilities" {
  default = ["EC2"]
  type    = list(string)
}

variable "launch_template_description" {
  default = "Launch template for the task3 ec2 instances"
  type    = string
}

variable "Launch_template_update_default" {
  description = "Value to determine if the default version for the launch template should update with each new version"
  type        = bool
  default     = true
}

variable "service_launch_type" {
  default     = "EC2"
  description = "ECS service launch type"
  type        = string
}

variable "load_balancer_type" {
  default     = "application"
  description = "Value to specify the type of load balancer"
  type        = string
}

variable "target_group_target_type" {
  default = "ip"
  type    = string
}

variable "alb_cross_zone" {
  default     = true
  type        = bool
  description = "Value to determine if the load balancer should spread across zones"
}

variable "healthcheck_threshold" {
  default     = 2
  type        = number
  description = "number of successful healthchecks needed to verify task is healthy"
}

variable "unhealthy_threshold" {
  default     = 2
  type        = number
  description = "number of failed healthchecks needed to verify task is unhealthy"
}

variable "healthcheck_matcher" {
  default     = "200"
  type        = string
  description = "Matcher to test the response code of the healthcheck"
}

variable "healthcheck_interval" {
  default     = 10
  type        = number
  description = "Interval between healthchecks"
}

variable "healthcheck_path" {
  default     = "/"
  type        = string
  description = "Path to the service's healthcheck"
}

variable "healthcheck_protocol" {
  default     = "HTTP"
  type        = string
  description = "Protocol for the service healthcheck"
}

variable "healthcheck_timeout" {
  default     = 5
  type        = number
  description = "Timeframe for the healthcheck until time out"
}

variable "alb_enable_deletion_protection" {
  default     = true
  type        = bool
  description = "Value to determine if the alb should have deletion protection"
}

variable "task_exec_policy_name" {
  default     = "AmazonECSTaskExecutionRolePolicy"
  type        = string
  description = "Name of existing AWS task execution policy to give task role"
}