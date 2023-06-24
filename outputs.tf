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