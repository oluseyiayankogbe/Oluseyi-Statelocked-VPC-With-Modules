
#vpc atttributes
project_name         = "tester"
region               = "us-west-1"
vpc_cidr             = "10.0.0.0/16"
enable_dns_hostnames = true
enable_dns_support   = true
#subnet attributes
descriptor1                                 = "web-test"
descriptor2                                 = "app-test"
public_subnets_cidr                         = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets_cidr                        = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zone                           = ["us-west-1b", "us-west-1c"]
map_public_ip_on_launch                     = true
enable_resource_name_dns_a_record_on_launch = true
instance_tenancy                            = "default"
#ec2 attributes
linux_instance_type = "t2.micro"
privateserver1              = "AppPrivate1Test"
privateserver2              = "AppPrivate2Test"
associate_public_ip_address = true
#dbsubnetgroup attributes
name = "dbsng"
#rds database attributes
allocated_storage     = 20
max_allocated_storage = 100
engine                = "postgres"
engine_version        = "14.7"
instance_class        = "db.t3.micro"
db_name               = "dbtest"
username              = "postgres"
password              = "administrator"
parameter_group_name  = "default.postgres14"
skip_final_snapshot   = true
db_subnet_group_name  = "dbsng"

#Iam profile attributes
role = "Reusable"

#Route53 Attributes
 #name                  = "doktorsanti.click"
 domain_name           = "doktorsanti.click"




