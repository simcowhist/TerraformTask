output "load_balancer_dns" {
     description = "The public ip of the load balancer"
     value = try(module.alb.dns_name)
}