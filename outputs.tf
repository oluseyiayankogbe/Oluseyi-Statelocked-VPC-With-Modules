output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

output "public-subnets_id" {
  value = module.vpc.public-subnets_id
}

output "private-subnets_id" {
  value = module.vpc.private-subnets_id
}

output "security-group_id" {
  value = module.vpc.security-group_id
}

output "alb-target-group_arn" {
  value = module.vpc.alb-target-group_arn
}

output "application-load-balancer_dns_name" {
  value = module.vpc.application-load-balancer_dns_name
}

output "application-load-balancer_zone_id" {
  value = module.vpc.application-load-balancer_zone_id
}

output "acm_certificate_arn" {
  value = module.vpc.acm_certificate_arn
}
