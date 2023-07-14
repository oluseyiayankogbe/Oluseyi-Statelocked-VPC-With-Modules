
module "vpc" {
  source = "./child-modules/vpc"
  #depends_on = [module.route-53.acm_certificate]

  #vpc atttributes
  project_name         = var.project_name
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  #subnet attributes
  descriptor1                                 = var.descriptor1
  descriptor2                                 = var.descriptor2
  public_subnets_cidr                         = var.public_subnets_cidr
  private_subnets_cidr                        = var.private_subnets_cidr
  availability_zone                           = var.availability_zone
  map_public_ip_on_launch                     = var.map_public_ip_on_launch
  enable_resource_name_dns_a_record_on_launch = var.enable_resource_name_dns_a_record_on_launch
  instance_tenancy                            = var.instance_tenancy
  #ec2 attributes
  linux_instance_type = var.linux_instance_type
  privateserver1              = var.privateserver1
  privateserver2              = var.privateserver2
  associate_public_ip_address = var.associate_public_ip_address
  #dbsubnetgroup attributes
  name = var.name
  #rds postgresql database attributes
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  engine                = var.engine
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  db_name               = var.db_name
  username              = var.username
  password              = var.password
  parameter_group_name  = var.parameter_group_name
  skip_final_snapshot   = var.skip_final_snapshot
  db_subnet_group_name  = var.db_subnet_group_name
  #alb attributes
  #certificate_arn       = module.route-53.acm_certificate_arn
  domain_name           = var.domain_name

}

module "key-pair" {
  source       = "./child-modules/key-pair"
  project_name = var.project_name
}

module "iam-profile" {
  source       = "./child-modules/iam-profile"
  project_name = var.project_name
  role         = var.role

}

#module "route-53" {
  #source                      = "./child-modules/route-53"
  #name                       = var.domain_name
  #domain_name                 = var.domain_name
  #certificate_arn       = var.certificate_arn

#}

