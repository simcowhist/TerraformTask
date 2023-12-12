locals {
  tags = {
    Terraform = "true"
    Environment = terraform.workspace
    Project = vars.project_name
  }
}
data "aws_availability_zones" "available" {
  state = "available"
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-vpc-${terraform.workspace}"
  cidr = var.vpc_cidr

  azs = data.aws_availability_zones.available.names

  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true

  tags = local.tags
}


module "autoscaling" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "${var.project_name}-asg-${terraform.workspace}"

  min_size = 2
  max_size = 4
  desired_capacity = 2
  vpc_zone_identifier = module.vpc.private_subnets

  launch_template_name = "${var.project_name}-ltmp-${terrafrm.workspace}"
  launch_template_description = "Launch template for the task3 ec2 instances"
  update_default_version = true

  image_id = var.instance_ami
  instance_type = var.instance_type
  
  create_iam_instance_profile = false
  iam_instance_profile_name = var.iam_instance_profile_arn

  user_data = base64encode(templatefile("user_data.tftpl", {cluster = module.ecs.cluster_name}))
  tags = local.tags
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "${var.project_name}-clst-${terraform.workspace}"

  default_capacity_provider_use_fargate = false
  autoscaling_capacity_providers = {
    asg = {
      auto_scaling_group_arn = module.autoscaling.autoscaling.group.arn
    }
  }
}
