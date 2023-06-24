#vpc attributes
variable "region" {}
variable "project_name" {}
variable "enable_dns_hostnames" {}
variable "enable_dns_support" {}
#subnet attributes
variable "descriptor1" {}
variable "descriptor2" {}
variable "vpc_cidr" {}
variable "availability_zone" {}
variable "public_subnets_cidr" {}
variable "private_subnets_cidr" {}
variable "map_public_ip_on_launch" {}
variable "enable_resource_name_dns_a_record_on_launch" {}
variable "instance_tenancy" {}
#ec2 attributes
variable "linux_instance_type" {}
variable "publicserver1" {}
variable "publicserver2" {}
variable "privateserver1" {}
variable "privateserver2" {}
variable "associate_public_ip_address" {}
#rds database attributes
variable "allocated_storage" {}
variable "engine" {}
variable "engine_version" {}
variable "instance_class" {}
variable "db_name" {}
variable "username" {}
variable "password" {}
variable "parameter_group_name" {}
variable "skip_final_snapshot" {}
variable "db_subnet_group_name" {}
#Iam profile attributes
variable "role" {}


