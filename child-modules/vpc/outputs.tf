output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "public-subnets_id" {
  value = aws_subnet.public-subnets[*]
}



output "private-subnets_id" {
  value = aws_subnet.private-subnets[*]
}


output "security-group_id" {
  value = aws_security_group.sg.id
}

output "alb-target-group_arn" {
  value = aws_lb_target_group.alb-target-group.arn
}

output "application-load-balancer_dns_name" {
  value = aws_lb.application-load-balancer.dns_name
}

output "application-load-balancer_zone_id" {
  value = aws_lb.application-load-balancer.zone_id
}


output "acm_certificate_arn" {
  value = aws_acm_certificate.acm_certificate.arn
}
