
#vpc atttributes
project_name         = "website-prod"
region               = "eu-west-2"
vpc_cidr             = "10.0.0.0/16"
enable_dns_hostnames = true
enable_dns_support   = true
#subnet attributes
descriptor1                                 = "web-prod"
descriptor2                                 = "app-prod"
public_subnets_cidr                         = ["10.0.10.0/24", "10.0.11.0/24"]
private_subnets_cidr                        = ["10.0.12.0/24", "10.0.13.0/24"]
availability_zone                           = ["eu-west-2a", "eu-west-2b"]
map_public_ip_on_launch                     = true
enable_resource_name_dns_a_record_on_launch = true
instance_tenancy                            = "default"
#ec2 attributes
linux_instance_type         = "t2.micro"
publicserver1               = "WebPublic1Prod"
publicserver2               = "WebPublic2Prod"
privateserver1              = "AppPrivate1Prod"
privateserver2              = "AppPrivate2Prod"
associate_public_ip_address = true
#rds database attributes
allocated_storage    = 20
engine               = "mysql"
engine_version       = "5.7.42"
instance_class       = "db.t3.micro"
db_name              = "dbprod"
username             = "admin"
password             = "administrator"
parameter_group_name = "default.mysql5.7"
skip_final_snapshot  = true
db_subnet_group_name = "dbsng"
#Iam profile attributes
role = "Reusable"



