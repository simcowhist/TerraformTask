data "aws_availability_zones" "available" {
  state = "available"
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-vpc-${terraform.workspace}"
  cidr = var.vpc_cidr

  azs = data.aws_availability_zones.available.names

  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  create_database_subnet_group = true

  enable_nat_gateway = true
}

module "public_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name                = "${var.project_name}-sg-public-${terraform.workspace}"
  description         = "Security group for load-balancer with HTTP ports open within VPC"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
}

module "private_security_group" {
  source              = "terraform-aws-modules/security-group/aws//modules/http-80"
  name                = "${var.project_name}-sg-priv-${terraform.workspace}"
  description         = "Security group for ec2 instances allowing access only from the public subnet"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
}

module "database_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name                = "${var.project_name}-dbsg-${terraform.workspace}"
  description         = "Security group for RDS instances"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  ingress_rules       = [3306, 3306, "tcp", "MySQL/Aurora"]
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.project_name}-rds-${terraform.workspace}"

  engine               = "mysql"
  major_engine_version = "8"
  engine_version       = "8.0"
  family               = "mysql8.0"
  instance_class       = "db.t3a.micro"
  allocated_storage    = 10

  db_name  = "${var.project_name}-database"
  port     = 3306
  username = "admin"

  vpc_security_group_ids = [module.database_security_group.security_group_id]
  multi_az               = var.db_multi_az
  db_subnet_group_name   = module.vpc.database_subnet_group

  manage_master_user_password = var.db_manage_master_password
}

resource "aws_ecs_task_definition" "task_def" {
  family = "${var.project_name}-tskdef-${terraform.workspace}"

  container_definitions = jsonencode([
    {
      name              = "web-app"
      cpu               = 0
      memory            = 512
      memoryReservation = 256
      image             = "930354804502.dkr.ecr.us-east-1.amazonaws.com/simcowhist"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/${var.project_name}-tskdef-${terraform.workspace}",
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
        secretOptions = []
      }
    }
  ])
  cpu    = 256
  memory = 512
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  requires_compatibilities = ["EC2"]
  task_role_arn            = "arn:aws:iam::930354804502:role/ecsTaskExecutionRole"
  execution_role_arn       = "arn:aws:iam::930354804502:role/ecsTaskExecutionRole"
  network_mode             = "awsvpc"
}

module "autoscaling" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "${var.project_name}-asg-${terraform.workspace}"

  min_size            = var.min_scaling_size
  max_size            = var.max_scaling_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = module.vpc.private_subnets
  security_groups     = [module.private_security_group.security_group_id]

  # launch template
  launch_template_name        = "${var.project_name}-ltmp-${terraform.workspace}"
  launch_template_description = "Launch template for the task3 ec2 instances"
  update_default_version      = true

  image_id      = var.instance_ami
  instance_type = var.instance_type
  instance_name = "${var.project_name}-inst-${terraform.workspace}"

  create_iam_instance_profile = false
  iam_instance_profile_arn    = var.iam_instance_profile_arn

  user_data = base64encode(templatefile("user_data.tftpl", { cluster = module.ecs_cluster.name }))
}

module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  cluster_name = "${var.project_name}-clst-${terraform.workspace}"

  default_capacity_provider_use_fargate = false
  autoscaling_capacity_providers = {
    asg = {
      auto_scaling_group_arn = module.autoscaling.autoscaling_group_arn
    }
  }
}

module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name        = "${var.project_name}-srvc-${terraform.workspace}"
  cluster_arn = module.ecs_cluster.arn

  create_task_definition = false
  task_definition_arn    = aws_ecs_task_definition.task_def.arn

  launch_type   = "EC2"
  desired_count = 2

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["${var.project_name}-tgrp-${terraform.workspace}"].arn
      container_name   = "web-app"
      container_port   = 80
    }
  }

  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [module.private_security_group.security_group_id]
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name               = "${var.project_name}-alb-${terraform.workspace}"
  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  security_groups = [module.public_security_group.security_group_id]
  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "${var.project_name}-tgrp-${terraform.workspace}"
      }
    }
  }

  target_groups = {
    "${var.project_name}-tgrp-${terraform.workspace}" = {
      backend_protocl                   = "HTTP"
      backend_port                      = 80
      target_type                       = "ip"
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/healthcheck"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
        unhealthy_threshold = 2
      }

      create_attachment = false
    }
  }
  enable_deletion_protection = false
}