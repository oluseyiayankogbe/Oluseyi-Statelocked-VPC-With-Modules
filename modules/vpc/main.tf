#START OF VPC PROVISION CODE

#1. Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

#2. Create public subnets

resource "aws_subnet" "public-subnets" {
  count                                       = length(var.public_subnets_cidr)
  vpc_id                                      = aws_vpc.vpc.id
  cidr_block                                  = var.public_subnets_cidr[count.index]
  availability_zone                           = var.availability_zone[count.index]
  map_public_ip_on_launch                     = var.map_public_ip_on_launch
  enable_resource_name_dns_a_record_on_launch = var.enable_resource_name_dns_a_record_on_launch

  tags = {
    Name = "${var.descriptor1}-public-subnet-${count.index+1}"
  }
}



#2c.Create private subnets
resource "aws_subnet" "private-subnets" {
  count             = length(var.private_subnets_cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "${var.descriptor2}-private-subnet-${count.index+1}"
  }
}



#3. Create Internet Gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-internet-gateway"
  }
}

#4. Create Elastic IP Adress
resource "aws_eip" "elastic-iP" {

  tags = {
    Name = "${var.project_name}-elastic-iP"
  }
}

#5. Create NAT Gateway
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.elastic-iP.id
  subnet_id     = aws_subnet.public-subnets[1].id
  

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }

}

#4. Create Route Tables

#4a.Create pub Route Table 
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id
  #The command below attaches the pulic route table to the Internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }


  tags = {
    Name = "${var.project_name}-public-route-table"
  }
}

#4b.Create priv Route Table 
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id
  #The command below attaches the private route table to the NAT gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    Name = "${var.project_name}-private-route-table"
  }
}

#5. Create All Networking Associations & Attachments
#5a. Attach public Route Table to public subnets
resource "aws_route_table_association" "Attach-pub-route-table-pub-subnets" {
  count          = length(var.public_subnets_cidr)
  subnet_id     = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.public-route-table.id
}



#5c. Attach private Route Table To private subnets
resource "aws_route_table_association" "Attach-priv-route-table-priv-subnets" {
  count          = length(var.private_subnets_cidr)
  subnet_id     = aws_subnet.private-subnets[count.index].id
  route_table_id = aws_route_table.private-route-table.id
}



#1. Create Security Group (With Outbound Rule Attached)


resource "aws_security_group" "sg" {
  name   = "${var.project_name}-sg"
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

#2a. Create Security Group Inbound Rule 1 (http)
resource "aws_security_group_rule" "sgr-1" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.sg.id
  cidr_blocks       = ["0.0.0.0/0"]

}

#2b. Create Security Group Inbound Rule 2 (ssh)
resource "aws_security_group_rule" "sgr-2" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.sg.id
  cidr_blocks       = ["0.0.0.0/0"]

}

#2c. Create Security Group Inbound Rule 3 (rds database)
resource "aws_security_group_rule" "sgr-3" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.sg.id
  cidr_blocks       = ["0.0.0.0/0"]

}

#1. Define The Data To Be Associated With The EC2 Instance
data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

#2. Define The Local Varying Values using the "locals" descriptor
locals {
  aws_instance = {
    "private-1" = { subnet_id = aws_subnet.private-subnets[0].id, tags = { Name = "${var.privateserver1}-ec2" } }
    "private-2" = { subnet_id = aws_subnet.private-subnets[1].id, tags = { Name = "${var.privateserver2}-ec2" } }
    "public-1"  = { subnet_id = aws_subnet.public-subnets[0].id, tags = { Name = "${var.publicserver1}-ec2" } }
    "public-2"  = { subnet_id = aws_subnet.public-subnets[1].id, tags = { Name = "${var.publicserver2}-ec2" } }
  }
}

#3. Create The EC2 Instance
resource "aws_instance" "ec2" {
  for_each                    = local.aws_instance
  subnet_id                   = each.value.subnet_id
  tags                        = each.value.tags
  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = var.linux_instance_type
  key_name                    = "${var.project_name}-key"
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  iam_instance_profile        = "${var.project_name}-profile"
  associate_public_ip_address = var.associate_public_ip_address

}


#0. Create DB Subnet Group

resource "aws_db_subnet_group" "dbsng" {
  name       = "dbsng"
  subnet_ids = [aws_subnet.private-subnets[0].id, aws_subnet.private-subnets[1].id]

  tags = {
    Name = "${var.project_name}-dbsng"
  }
}

#0. Create RDS

resource "aws_db_instance" "database" {
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  parameter_group_name   = var.parameter_group_name
  skip_final_snapshot    = var.skip_final_snapshot
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  db_subnet_group_name   = var.db_subnet_group_name

}






