data "aws_availability_zones" "available" {
  state = "available"
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-vpc-${terraform.workspace}"
  cidr = var.vpc_cidr

  azs = data.aws_availability_zones.available.names

  private_subnets = ["192.168.1.0/24"]
  public_subnets  = ["192.168.101.0/24"]

  enable_nat_gateway = true
}

module "public_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name                = "${var.project_name}-sg-public-${terraform.workspace}"
  description         = "Security group for load-balancer with HTTP ports open within VPC"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
}

module "private_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name                = "${var.project_name}-sg-priv-${terraform.workspace}"
  description         = "Security group for ec2 instances allowing access only from the public subnet"
  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
  ingress_rules = ["http-80-tcp"]
}

module "autoscaling" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "${var.project_name}-asg-${terraform.workspace}"

  min_size            = var.min_scaling_size
  max_size            = var.max_scaling_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = module.vpc.private_subnets
  security_groups = [module.private_security_group.security_group_id]

  # launch template
  launch_template_name        = "${var.project_name}-ltmp-${terraform.workspace}"
  launch_template_description = "Launch template for the task3 ec2 instances"
  update_default_version      = true

  image_id      = var.instance_ami
  instance_type = var.instance_type
  instance_name = "${var.project_name}-inst-${terraform.workspace}"

  create_iam_instance_profile = false
  iam_instance_profile_arn    = var.iam_instance_profile_arn

  user_data = base64encode(templatefile("user_data.tftpl", { cluster = module.ecs.cluster_name }))
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "${var.project_name}-clst-${terraform.workspace}"

  default_capacity_provider_use_fargate = false
  autoscaling_capacity_providers = {
    asg = {
      auto_scaling_group_arn = module.autoscaling.autoscaling_group_arn
    }
  }
}