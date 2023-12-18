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

  create_database_subnet_group = var.create_database_subnet_group

  enable_nat_gateway = var.enable_nat_gateway
}

module "public_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name                = "${var.project_name}-sg-public-${terraform.workspace}"
  description         = "Security group for load-balancer with HTTP ports open within VPC"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = var.public_security_group_ingress_cidr_blocks
  ingress_rules       = var.public_security_group_ingress_rules
  egress_cidr_blocks  = module.vpc.private_subnets_cidr_blocks
  egress_rules        = var.public_security_group_egress_rules
}

module "private_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name                = "${var.project_name}-sg-priv-${terraform.workspace}"
  description         = "Security group for ec2 instances allowing access only from the public subnet"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
  ingress_rules       = var.private_security_group_ingress_rules
  egress_cidr_blocks  = var.private_security_group_egress_cidr_blocks
  egress_rules        = var.private_security_group_egress_rules
}

module "database_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.project_name}-dbsg-${terraform.workspace}"
  description = "Security group for RDS instances"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = var.db_port
      to_port     = var.db_port
      protocol    = var.db_security_group_protocol
      description = "MySQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.project_name}-rds-${terraform.workspace}"

  engine               = var.db_engine
  major_engine_version = var.db_major_engine_version
  engine_version       = var.db_engine_version
  family               = var.db_family
  instance_class       = var.db_instance_type
  allocated_storage    = var.db_allocated_stroage

  db_name  = var.project_name
  port     = var.db_port
  username = var.db_master_user

  vpc_security_group_ids = [module.database_security_group.security_group_id]
  multi_az               = var.db_multi_az
  db_subnet_group_name   = module.vpc.database_subnet_group

  manage_master_user_password = var.db_manage_master_password
  skip_final_snapshot         = var.skip_final_snapshot
}

resource "aws_ecs_task_definition" "task_def" {
  family = "${var.project_name}-tskdef-${terraform.workspace}"

  container_definitions = jsonencode([
    {
      name              = var.webapp_container_name
      cpu               = var.webapp_cpu
      memory            = var.webapp_memory_hard_limit
      memoryReservation = var.webapp_memory_soft_limit
      image             = var.webapp_image

      portMappings = [
        {
          containerPort = var.webapp_container_port
          hostPort      = var.webapp_host_port
          protocol      = var.webapp_protocol
          appProtocol   = lower(var.webapp_app_protocol)
        }
      ]
      essential = var.webapp_essential
      logConfiguration = {
        logDriver = var.webapp_log_driver
        options = {
          awslogs-create-group  = var.aws_logs_create_group
          awslogs-group         = "/${var.aws_logs_stream_prefix}/${var.project_name}-tskdef-${terraform.workspace}",
          awslogs-region        = var.region
          awslogs-stream-prefix = var.aws_logs_stream_prefix
        }
        secretOptions = []
      }
      secrets : [{
        name = "DB_USER"
        valueFrom : "${module.db.db_instance_master_user_secret_arn}:username::"
        },
        {
          name = "DB_PASSWORD"
          valueFrom : "${module.db.db_instance_master_user_secret_arn}:password::"
      }]
      environment = [
        {
          name  = "DB_NAME"
          value = var.project_name
        },
        {
          name  = "DB_HOST"
          value = element(split(":", module.db.db_instance_endpoint), 0)
        }
      ]
    }
  ])
  cpu    = var.task_cpu
  memory = var.task_memory
  runtime_platform {
    cpu_architecture        = var.webapp_runtime_platform_cpu_architecture
    operating_system_family = var.webapp_runtime_platform_operating_system_family
  }
  requires_compatibilities = var.task_def_requiers_compatabilities
  execution_role_arn       = aws_iam_role.task_role.arn
  network_mode             = var.webapp_network_mode
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
  launch_template_description = var.launch_template_description
  update_default_version      = var.Launch_template_update_default

  image_id      = var.instance_ami
  instance_type = var.instance_type
  instance_name = "${var.project_name}-inst-${terraform.workspace}"

  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 30
        volume_type           = "gp3"
        delete_on_termination = true
      }
    }
  ]

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

  launch_type   = var.service_launch_type
  desired_count = var.desired_task_count

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["${var.project_name}-tgrp-${terraform.workspace}"].arn
      container_name   = var.webapp_container_name
      container_port   = var.webapp_container_port
    }
  }

  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [module.private_security_group.security_group_id]
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name               = "${var.project_name}-alb-${terraform.workspace}"
  load_balancer_type = "application"

  vpc_id   = module.vpc.vpc_id
  subnets  = module.vpc.public_subnets
  internal = var.alb_internal

  security_groups = [module.public_security_group.security_group_id]
  listeners = {
    http = {
      port     = var.webapp_container_port
      protocol = var.webapp_app_protocol
      forward = {
        target_group_key = "${var.project_name}-tgrp-${terraform.workspace}"
      }
    }
  }

  target_groups = {
    "${var.project_name}-tgrp-${terraform.workspace}" = {
      backend_protocl                   = var.webapp_app_protocol
      backend_port                      = var.webapp_container_port
      target_type                       = var.target_group_target_type
      load_balancing_cross_zone_enabled = var.alb_cross_zone

      health_check = {
        enabled             = true
        healthy_threshold   = var.healthcheck_threshold
        interval            = var.healthcheck_interval
        matcher             = var.healthcheck_matcher
        path                = var.healthcheck_path
        protocol            = var.healthcheck_protocol
        timeout             = var.healthcheck_timeout
        unhealthy_threshold = var.unhealthy_threshold
      }

      create_attachment = false
    }
  }
  enable_deletion_protection = var.alb_enable_deletion_protection
}

resource "aws_iam_role" "task_role" {
  name = "${var.project_name}-taskrole-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "TaskGetSecretPolicy"
    policy = jsonencode({

      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "Statement1"
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Resource = "${module.db.db_instance_master_user_secret_arn}"
        }
      ]
    })
  }
}
data "aws_iam_policy" "task_exec_policy" {
  name = var.task_exec_policy_name
}

resource "aws_iam_role_policy_attachment" "task_exec_role_policy_attach" {
  role       = aws_iam_role.task_role.name
  policy_arn = data.aws_iam_policy.task_exec_policy.arn
}

resource "aws_autoscaling_policy" "webapp_scale_up" {
  name                      = "${var.project_name}-scale-up-policy-${terraform.workspace}"
  policy_type               = var.scaling_type
  adjustment_type           = var.scaling_adjustment_type
  autoscaling_group_name    = module.autoscaling.autoscaling_group_name
  estimated_instance_warmup = var.estimated_instance_warmup

  step_adjustment {
    metric_interval_upper_bound = var.upscale_policy_lower_bound
    scaling_adjustment          = var.scale_up_adjustment
  }
}

resource "aws_autoscaling_policy" "webapp_scale_down" {
  name                      = "${var.project_name}-scale-down-policy-${terraform.workspace}"
  policy_type               = var.scaling_type
  adjustment_type           = var.scaling_adjustment_type
  autoscaling_group_name    = module.autoscaling.autoscaling_group_name
  estimated_instance_warmup = var.estimated_instance_warmup

  step_adjustment {
    scaling_adjustment          = var.scale_down_adjustment
    metric_interval_upper_bound = var.downscale_policy_upper_bound
  }

}

resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_name          = "${var.project_name}-cpu-scale-up-${terraform.workspace}"
  comparison_operator = var.upscale_alarm_comparison_operator
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = var.alarm_metric_name
  namespace           = var.alarm_namepsace
  period              = var.alarm_period
  statistic           = var.alarm_statistic
  threshold           = var.upscale_alarm_threshold
  alarm_description   = "This metric monitors ECS Cluster cpu utilization going up"
  alarm_actions       = [aws_autoscaling_policy.webapp_scale_up.arn]
  dimensions = {
    ClusterName = module.ecs_cluster.name
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_name          = "${var.project_name}-cpu-scale-down-${terraform.workspace}"
  comparison_operator = var.downscale_alarm_comparison_operator
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = var.alarm_metric_name
  namespace           = var.alarm_namepsace
  period              = var.alarm_period
  statistic           = var.alarm_statistic
  threshold           = var.downscale_alarm_threshold
  alarm_description   = "This metric monitors ECS Cluster cpu utilization going down"
  alarm_actions       = [aws_autoscaling_policy.webapp_scale_down.arn]
  dimensions = {
    ClusterName = module.ecs_cluster.name
  }
}