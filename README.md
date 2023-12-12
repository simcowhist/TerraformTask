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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment | `string` | `"development"` | no |
| <a name="input_instance_ami"></a> [instance\_ami](#input\_instance\_ami) | AMI to be used in EC2 instances | `string` | `"ami-0c9db8d36d76d38ed"` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Value of the Name Tag for the EC2 instance | `string` | `"task3-instance-dev"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instace type to be used in EC2 instances | `string` | `"t3.micro"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the vpc | `string` | `"task3-vpc-dev"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->