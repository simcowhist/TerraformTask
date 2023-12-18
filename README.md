# Applying terraform knowledge.
In this project we attempt to create a ECS cluster with an auto scaling group
pulling the image for the containers from ECR,
and finally connecting the running instances to an RDS server,
all with terraform.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= v1.6.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.30.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | n/a |
| <a name="module_autoscaling"></a> [autoscaling](#module\_autoscaling) | terraform-aws-modules/autoscaling/aws | n/a |
| <a name="module_database_security_group"></a> [database\_security\_group](#module\_database\_security\_group) | terraform-aws-modules/security-group/aws | n/a |
| <a name="module_db"></a> [db](#module\_db) | terraform-aws-modules/rds/aws | n/a |
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | terraform-aws-modules/ecs/aws//modules/cluster | n/a |
| <a name="module_ecs_service"></a> [ecs\_service](#module\_ecs\_service) | terraform-aws-modules/ecs/aws//modules/service | n/a |
| <a name="module_private_security_group"></a> [private\_security\_group](#module\_private\_security\_group) | terraform-aws-modules/security-group/aws | n/a |
| <a name="module_public_security_group"></a> [public\_security\_group](#module\_public\_security\_group) | terraform-aws-modules/security-group/aws | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_policy.webapp_scale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.webapp_scale_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_cloudwatch_metric_alarm.scale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.scale_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ecs_task_definition.task_def](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.task_exec_role_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy.task_exec_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_Launch_template_update_default"></a> [Launch\_template\_update\_default](#input\_Launch\_template\_update\_default) | Value to determine if the default version for the launch template should update with each new version | `bool` | `true` | no |
| <a name="input_alarm_evaluation_periods"></a> [alarm\_evaluation\_periods](#input\_alarm\_evaluation\_periods) | The amount of periods for the alarm to evalulate before triggering | `number` | `1` | no |
| <a name="input_alarm_metric_name"></a> [alarm\_metric\_name](#input\_alarm\_metric\_name) | The name of the metric to test | `string` | `"CPUUtilization"` | no |
| <a name="input_alarm_namepsace"></a> [alarm\_namepsace](#input\_alarm\_namepsace) | n/a | `string` | `"AWS/ECS"` | no |
| <a name="input_alarm_period"></a> [alarm\_period](#input\_alarm\_period) | The time in seconds for an alarm to test in order to trigger | `number` | `30` | no |
| <a name="input_alarm_statistic"></a> [alarm\_statistic](#input\_alarm\_statistic) | The type of statistic for the alarm to test | `string` | `"Average"` | no |
| <a name="input_alb_create_security_group"></a> [alb\_create\_security\_group](#input\_alb\_create\_security\_group) | Value to determine if a separate security group should be created for the alb | `bool` | `false` | no |
| <a name="input_alb_cross_zone"></a> [alb\_cross\_zone](#input\_alb\_cross\_zone) | Value to determine if the load balancer should spread across zones | `bool` | `true` | no |
| <a name="input_alb_enable_deletion_protection"></a> [alb\_enable\_deletion\_protection](#input\_alb\_enable\_deletion\_protection) | Value to determine if the alb should have deletion protection | `bool` | `true` | no |
| <a name="input_alb_internal"></a> [alb\_internal](#input\_alb\_internal) | Value to determine if the alb is internal or internet facing | `bool` | `false` | no |
| <a name="input_aws_logs_create_group"></a> [aws\_logs\_create\_group](#input\_aws\_logs\_create\_group) | if to create aws log group | `string` | `"true"` | no |
| <a name="input_aws_logs_stream_prefix"></a> [aws\_logs\_stream\_prefix](#input\_aws\_logs\_stream\_prefix) | Prefix for the aws logs stream | `string` | `"ecs"` | no |
| <a name="input_create_database_subnet_group"></a> [create\_database\_subnet\_group](#input\_create\_database\_subnet\_group) | Value to determine if to create a database subnet group | `bool` | `true` | no |
| <a name="input_database_subnets"></a> [database\_subnets](#input\_database\_subnets) | IP ranges for database subnets | `list(string)` | <pre>[<br>  "10.0.201.0/24"<br>]</pre> | no |
| <a name="input_db_allocated_stroage"></a> [db\_allocated\_stroage](#input\_db\_allocated\_stroage) | Allocated storage of the db in GB | `number` | `10` | no |
| <a name="input_db_engine"></a> [db\_engine](#input\_db\_engine) | What db to use | `string` | `"mysql"` | no |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | The version of the db engine | `string` | `"8.0"` | no |
| <a name="input_db_family"></a> [db\_family](#input\_db\_family) | The db family name | `string` | `"mysql8.0"` | no |
| <a name="input_db_instance_type"></a> [db\_instance\_type](#input\_db\_instance\_type) | AWS Instace type of the db | `string` | `"db.r5.large"` | no |
| <a name="input_db_major_engine_version"></a> [db\_major\_engine\_version](#input\_db\_major\_engine\_version) | The major version of the db engine | `string` | `"8.0"` | no |
| <a name="input_db_manage_master_password"></a> [db\_manage\_master\_password](#input\_db\_manage\_master\_password) | Value to determine if aws should manage the database's master password | `bool` | `true` | no |
| <a name="input_db_master_user"></a> [db\_master\_user](#input\_db\_master\_user) | Name of the master user in the database | `string` | `"admin"` | no |
| <a name="input_db_multi_az"></a> [db\_multi\_az](#input\_db\_multi\_az) | Value to determine if database instance should be across multiple az | `bool` | `true` | no |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | Port to be used for communiation with db | `string` | `"3306"` | no |
| <a name="input_db_security_group_protocol"></a> [db\_security\_group\_protocol](#input\_db\_security\_group\_protocol) | What protocol the db security group uses | `string` | `"tcp"` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | desired instance capcity for the auto scaling group | `number` | `0` | no |
| <a name="input_desired_task_count"></a> [desired\_task\_count](#input\_desired\_task\_count) | Amount of desired tasks to run | `number` | `2` | no |
| <a name="input_downscale_alarm_comparison_operator"></a> [downscale\_alarm\_comparison\_operator](#input\_downscale\_alarm\_comparison\_operator) | The type of comparison operator for the upscale alarm | `string` | `"LessThanOrEqualToThreshold"` | no |
| <a name="input_downscale_alarm_threshold"></a> [downscale\_alarm\_threshold](#input\_downscale\_alarm\_threshold) | The threshold for the downscale alarm to be triggered | `number` | `40` | no |
| <a name="input_downscale_policy_upper_bound"></a> [downscale\_policy\_upper\_bound](#input\_downscale\_policy\_upper\_bound) | n/a | `number` | `0` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Value to determine if to create a nat gateway | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment | `string` | `"development"` | no |
| <a name="input_estimated_instance_warmup"></a> [estimated\_instance\_warmup](#input\_estimated\_instance\_warmup) | Estimated time in seconds for an instance to be ready for use | `number` | `30` | no |
| <a name="input_healthcheck_interval"></a> [healthcheck\_interval](#input\_healthcheck\_interval) | Interval between healthchecks | `number` | `10` | no |
| <a name="input_healthcheck_matcher"></a> [healthcheck\_matcher](#input\_healthcheck\_matcher) | Matcher to test the response code of the healthcheck | `string` | `"200"` | no |
| <a name="input_healthcheck_path"></a> [healthcheck\_path](#input\_healthcheck\_path) | Path to the service's healthcheck | `string` | `"/"` | no |
| <a name="input_healthcheck_protocol"></a> [healthcheck\_protocol](#input\_healthcheck\_protocol) | Protocol for the service healthcheck | `string` | `"HTTP"` | no |
| <a name="input_healthcheck_threshold"></a> [healthcheck\_threshold](#input\_healthcheck\_threshold) | number of successful healthchecks needed to verify task is healthy | `number` | `2` | no |
| <a name="input_healthcheck_timeout"></a> [healthcheck\_timeout](#input\_healthcheck\_timeout) | Timeframe for the healthcheck until time out | `number` | `5` | no |
| <a name="input_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#input\_iam\_instance\_profile\_arn) | The iam instance profile for the ec2 instances | `string` | `"arn:aws:iam::930354804502:instance-profile/ecsInstanceRole"` | no |
| <a name="input_instance_ami"></a> [instance\_ami](#input\_instance\_ami) | AMI to be used in EC2 instances | `string` | `"ami-0c9db8d36d76d38ed"` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Value of the Name Tag for the EC2 instance | `string` | `"task3-instance-dev"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instace type to be used in EC2 instances | `string` | `"t3.large"` | no |
| <a name="input_launch_template_description"></a> [launch\_template\_description](#input\_launch\_template\_description) | n/a | `string` | `"Launch template for the task3 ec2 instances"` | no |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | Value to specify the type of load balancer | `string` | `"application"` | no |
| <a name="input_max_scaling_size"></a> [max\_scaling\_size](#input\_max\_scaling\_size) | maximum amount of instances for the auto scaling group | `number` | `0` | no |
| <a name="input_min_scaling_size"></a> [min\_scaling\_size](#input\_min\_scaling\_size) | minimum amount of instances for the auto scaling group | `number` | `0` | no |
| <a name="input_private_security_group_egress_cidr_blocks"></a> [private\_security\_group\_egress\_cidr\_blocks](#input\_private\_security\_group\_egress\_cidr\_blocks) | What cidr blocks is the private security group allowed to access | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_private_security_group_egress_rules"></a> [private\_security\_group\_egress\_rules](#input\_private\_security\_group\_egress\_rules) | What egress rules the private security group has | `list(string)` | <pre>[<br>  "all-all"<br>]</pre> | no |
| <a name="input_private_security_group_ingress_rules"></a> [private\_security\_group\_ingress\_rules](#input\_private\_security\_group\_ingress\_rules) | What ingress rules the private security group has | `list(string)` | <pre>[<br>  "http-80-tcp"<br>]</pre> | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | IP ranges for public subnets | `list(string)` | <pre>[<br>  "10.0.1.0/24"<br>]</pre> | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project, to be used as a prefix for resource names | `string` | `"task3"` | no |
| <a name="input_public_security_group_egress_rules"></a> [public\_security\_group\_egress\_rules](#input\_public\_security\_group\_egress\_rules) | What egress rules the public security group has | `list(string)` | <pre>[<br>  "all-all"<br>]</pre> | no |
| <a name="input_public_security_group_ingress_cidr_blocks"></a> [public\_security\_group\_ingress\_cidr\_blocks](#input\_public\_security\_group\_ingress\_cidr\_blocks) | What ingress cidr blocks are allowed to the public security group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_public_security_group_ingress_rules"></a> [public\_security\_group\_ingress\_rules](#input\_public\_security\_group\_ingress\_rules) | What ingress rules the public security group has | `list(string)` | <pre>[<br>  "http-80-tcp"<br>]</pre> | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | IP ranges for public subnets | `list(string)` | <pre>[<br>  "10.0.101.0/24",<br>  "10.0.102.0/24"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | Name of the aws region | `string` | `"us-east-1"` | no |
| <a name="input_scale_down_adjustment"></a> [scale\_down\_adjustment](#input\_scale\_down\_adjustment) | Amount of instances to be adjusted when scaling down | `number` | `2` | no |
| <a name="input_scale_up_adjustment"></a> [scale\_up\_adjustment](#input\_scale\_up\_adjustment) | Amount of instances to be adjusted when scaling up | `number` | `4` | no |
| <a name="input_scaling_adjustment_type"></a> [scaling\_adjustment\_type](#input\_scaling\_adjustment\_type) | The adjustment type for the scaling policies | `string` | `"ExactCapacity"` | no |
| <a name="input_scaling_type"></a> [scaling\_type](#input\_scaling\_type) | The type of scaling policy to use | `string` | `"StepScaling"` | no |
| <a name="input_service_launch_type"></a> [service\_launch\_type](#input\_service\_launch\_type) | ECS service launch type | `string` | `"EC2"` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Value to determine if final snapshot should be skipped or not. | `bool` | `false` | no |
| <a name="input_target_group_target_type"></a> [target\_group\_target\_type](#input\_target\_group\_target\_type) | n/a | `string` | `"ip"` | no |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | Cpu allocation for the task | `number` | `256` | no |
| <a name="input_task_def_requiers_compatabilities"></a> [task\_def\_requiers\_compatabilities](#input\_task\_def\_requiers\_compatabilities) | n/a | `list(string)` | <pre>[<br>  "EC2"<br>]</pre> | no |
| <a name="input_task_exec_policy_name"></a> [task\_exec\_policy\_name](#input\_task\_exec\_policy\_name) | Name of existing AWS task execution policy to give task role | `string` | `"AmazonECSTaskExecutionRolePolicy"` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | Memory allocation for the task | `number` | `512` | no |
| <a name="input_unhealthy_threshold"></a> [unhealthy\_threshold](#input\_unhealthy\_threshold) | number of failed healthchecks needed to verify task is unhealthy | `number` | `2` | no |
| <a name="input_upscale_alarm_comparison_operator"></a> [upscale\_alarm\_comparison\_operator](#input\_upscale\_alarm\_comparison\_operator) | The type of comparison operator for the upscale alarm | `string` | `"GreaterThanOrEqualToThreshold"` | no |
| <a name="input_upscale_alarm_threshold"></a> [upscale\_alarm\_threshold](#input\_upscale\_alarm\_threshold) | The threshold for the upscale alarm to be triggered | `number` | `60` | no |
| <a name="input_upscale_policy_lower_bound"></a> [upscale\_policy\_lower\_bound](#input\_upscale\_policy\_lower\_bound) | n/a | `number` | `0` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC cider to use | `string` | `"10.0.0.0/16"` | no |
| <a name="input_webapp_app_protocol"></a> [webapp\_app\_protocol](#input\_webapp\_app\_protocol) | Protocol for the application | `string` | `"HTTP"` | no |
| <a name="input_webapp_container_name"></a> [webapp\_container\_name](#input\_webapp\_container\_name) | Name of the container to be run | `string` | `"webapp"` | no |
| <a name="input_webapp_container_port"></a> [webapp\_container\_port](#input\_webapp\_container\_port) | Port for the container to listen on | `number` | `80` | no |
| <a name="input_webapp_cpu"></a> [webapp\_cpu](#input\_webapp\_cpu) | amount of cpu allocation for webapp container | `number` | `0` | no |
| <a name="input_webapp_essential"></a> [webapp\_essential](#input\_webapp\_essential) | Value to determine if the webapp container is essential | `bool` | `true` | no |
| <a name="input_webapp_host_port"></a> [webapp\_host\_port](#input\_webapp\_host\_port) | Port for the host machine to listen on | `number` | `80` | no |
| <a name="input_webapp_image"></a> [webapp\_image](#input\_webapp\_image) | Image url for the webapp container | `string` | `"930354804502.dkr.ecr.us-east-1.amazonaws.com/simcowhist"` | no |
| <a name="input_webapp_log_driver"></a> [webapp\_log\_driver](#input\_webapp\_log\_driver) | what log driver to use | `string` | `"awslogs"` | no |
| <a name="input_webapp_memory_hard_limit"></a> [webapp\_memory\_hard\_limit](#input\_webapp\_memory\_hard\_limit) | Hard limit memory allocation in MB | `number` | `512` | no |
| <a name="input_webapp_memory_soft_limit"></a> [webapp\_memory\_soft\_limit](#input\_webapp\_memory\_soft\_limit) | Soft limit memory allocation in MB | `number` | `256` | no |
| <a name="input_webapp_network_mode"></a> [webapp\_network\_mode](#input\_webapp\_network\_mode) | Network mode for the webapp containers | `string` | `"awsvpc"` | no |
| <a name="input_webapp_protocol"></a> [webapp\_protocol](#input\_webapp\_protocol) | n/a | `string` | `"TCP"` | no |
| <a name="input_webapp_runtime_platform_cpu_architecture"></a> [webapp\_runtime\_platform\_cpu\_architecture](#input\_webapp\_runtime\_platform\_cpu\_architecture) | n/a | `string` | `"X86_64"` | no |
| <a name="input_webapp_runtime_platform_operating_system_family"></a> [webapp\_runtime\_platform\_operating\_system\_family](#input\_webapp\_runtime\_platform\_operating\_system\_family) | n/a | `string` | `"LINUX"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_dns"></a> [load\_balancer\_dns](#output\_load\_balancer\_dns) | The public ip of the load balancer |
<!-- END_TF_DOCS -->