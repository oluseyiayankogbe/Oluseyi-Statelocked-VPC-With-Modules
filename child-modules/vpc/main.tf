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
  from_port         = 5432
  to_port           = 5432
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

resource "aws_db_subnet_group" "dbsubnetgroup" {
  name       = "${var.project_name}-dbsng"
  subnet_ids = [aws_subnet.private-subnets[0].id, aws_subnet.private-subnets[1].id]

  tags = {
    Name = "${var.project_name}-dbsng"
  }
}



#0. Create RDS

resource "aws_db_instance" "database" {
  allocated_storage      = var.allocated_storage
  max_allocated_storage  = var.max_allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  parameter_group_name   = var.parameter_group_name
  skip_final_snapshot    = var.skip_final_snapshot
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.dbsubnetgroup.name}"

}
#Configure the RDS provider
terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
    }
  }

 
}

#Create Route 53 Zone
resource "aws_route53_zone" "route53_zone" {
  name = var.domain_name
}
#Create an ACM Certificate
resource "aws_acm_certificate" "acm_certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "route53_record_dns" {
  allow_overwrite = true
  name =  tolist(aws_acm_certificate.acm_certificate.domain_validation_options)[0].resource_record_name
  records = [tolist(aws_acm_certificate.acm_certificate.domain_validation_options)[0].resource_record_value]
  type = tolist(aws_acm_certificate.acm_certificate.domain_validation_options)[0].resource_record_type
  zone_id = aws_route53_zone.route53_zone.zone_id
  ttl = 60
}

#resource "aws_acm_certificate_validation" "acm_cert_validate" {
  #certificate_arn = aws_acm_certificate.acm_certificate.arn
  #validation_record_fqdns = [aws_route53_record.route53_record_dns.fqdn]
#}

# create application load balancer
resource "aws_lb" "application-load-balancer" {
  name               = "application-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.sg.id}"]
  subnets            = [aws_subnet.public-subnets[0].id, aws_subnet.public-subnets[1].id]
  enable_deletion_protection = false

  tags   = {
    Name = "${var.project_name}-application-load-balancer"
  }
}

# create target group
resource "aws_lb_target_group" "alb-target-group" {
  name        = "alb-target-group"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

# create a listener on port 80 with redirect action
resource "aws_lb_listener" "alb-http-listener" {
  load_balancer_arn = aws_lb.application-load-balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# create a listener on port 443 with forward action
#resource "aws_lb_listener" "alb-https-listener" {
  #load_balancer_arn  = aws_lb.application-load-balancer.arn
  #port               = 443
  #protocol           = "HTTPS"
  #ssl_policy         = "ELBSecurityPolicy-2016-08"
  #certificate_arn    = aws_acm_certificate.acm_certificate.arn
  
  #default_action {
    #type             = "forward"
    #target_group_arn = aws_lb_target_group.alb-target-group.arn
  #}

  #depends_on = [aws_acm_certificate_validation.acm_cert_validate]
#}



resource "aws_launch_template" "launch-template" {
  name = "${var.project_name}-launch-template"

  #block_device_mappings {
    #device_name = "/dev/sda1"

    #ebs {
      #volume_size = 20
    #}
  #}

  #capacity_reservation_specification {
    #capacity_reservation_preference = "open"
  #}

  #cpu_options {
    #core_count       = 4
    #threads_per_core = 2
  #}

  credit_specification {
    cpu_credits = "standard"
  }

  #disable_api_termination = true

  ebs_optimized = true

  #elastic_gpu_specifications {
    #type = "test"
  #}

  #elastic_inference_accelerator {
    #type = "eia1.medium"
  #}

  iam_instance_profile {
    name = "Reusable"
  }

  image_id = data.aws_ami.amazon-linux-2.id

  instance_initiated_shutdown_behavior = "terminate"

  #instance_market_options {
    #market_type = "spot"
  #}

  instance_type = "t3a.micro"

  #kernel_id = "test"

  #key_name = "test"

  #license_specification {
    #license_configuration_arn = "arn:aws:license-manager:eu-west-1:123456789012:license-configuration:lic-0123456789abcdef0123456789abcdef"
  #}

  #metadata_options {
    #http_endpoint               = "enabled"
    #http_tokens                 = "required"
    #http_put_response_hop_limit = 1
  #}

  monitoring {
    enabled = true
  }

  #network_interfaces {
    #associate_public_ip_address = true
  #}

  placement {
    availability_zone = "us-west-1c"
  }

  #ram_disk_id = "test"

  vpc_security_group_ids = ["${aws_security_group.sg.id}"]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-ec2"
      Source = "Autoscaling"
    }
  }

  #user_data = filebase64("${path.module}/example.sh")
}

#resource "aws_placement_group" "placement-group" {
  #name     = "${var.project_name}-placement-group"
  #strategy = "cluster"
#}

resource "aws_autoscaling_group" "autoscaling-group" {
  name                      = "${var.project_name}-autoscaling-group"
  max_size                  = 5
  min_size                  = 2
  desired_capacity          = 3
  termination_policies      = ["OldestInstance"]
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  #placement_group           = aws_placement_group.placement-group.id
  #launch_template           = aws_launch_template.launch-template.name
  #availability_zones        = var.availability_zone[count.index]
  vpc_zone_identifier       = [aws_subnet.public-subnets[0].id, aws_subnet.public-subnets[1].id]
  
  launch_template {
    id = aws_launch_template.launch-template.id
    version = "$Latest"
  }

  #initial_lifecycle_hook {
    #name                 = "foobar"
    #default_result       = "CONTINUE"
    #heartbeat_timeout    = 2000
    #lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

    #notification_metadata = <<EOF
#{
  #"foo": "bar"
#}
#EOF

    #notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
    #role_arn                = "arn:aws:iam::123456789012:role/S3Access"
  #}

  #tag {
    #key                 = "foo"
    #value               = "bar"
    #propagate_at_launch = true
  #}

  #timeouts {
    #delete = "15m"
  #}

  #tag {
    #key                 = "lorem"
    #value               = "ipsum"
    #propagate_at_launch = false
  #}
}






