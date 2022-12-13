terraform {
  backend "s3" {
    key = "global/s3/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-2"
}

#image used for vm cluster
resource "aws_launch_configuration" "ptg-image-template" {
  image_id        = "ami-0fb653ca2d3203ac1"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.ptg-allow-web-traffic.id]

  #user_data is a boot startup script in ec2(virtual machienes) terminology for aws
  user_data = <<-EOF
              #!/bin/bash
              echo "Philtest hello!" > index.html
              nohup busybox httpd -f -p ${var.ptg-web-port} &
              EOF

  #so that terraform will not destroy first, it creates new instances first before destroying the old one
  lifecycle {
    create_before_destroy = true
  }
}

#launch instances from ptg image template
resource "aws_autoscaling_group" "ptg-mig" {
  launch_configuration = aws_launch_configuration.ptg-image-template.name
  vpc_zone_identifier = data.aws_subnets.ptg-subnets.ids

  target_group_arns = [aws_lb_target_group.ptg-tg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 4
  
  tag {
    key                 = "Name"
    value               = "ptg-webservers"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "ptg-allow-web-traffic" {
  name = "ptg-allow-web-traffic"

  ingress {
    from_port = var.ptg-web-port
    to_port   = var.ptg-web-port
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

#data is used to query provider api, for this example it's to get the default vpc
data "aws_vpc" "ptg-vpc" {
  default = true
}

data "aws_subnets" "ptg-subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.ptg-vpc.id] 
  }
}

resource "aws_lb" "ptg-alb" {
  name               = "ptg-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.ptg-subnets.ids
  security_groups = [aws_security_group.ptg-alb-sg.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ptg-alb.arn
  port              = 80
  protocol          = "HTTP"

  # default return 404
  default_action {
    type = "fixed-response"
    
    fixed_response {
      content_type = "text/plain"
      message_body = "404 pagenotfound"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "ptg-alb-sg" {
   name = "ptg-alb-sg"

   #allow inbound http req
   ingress {
     from_port = 80
     to_port   = 80
     protocol  = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   #allow all outbounds
   egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"] 
   }
}

resource "aws_lb_target_group" "ptg-tg" {
  name     = "ptg-tg"
  port     = var.ptg-web-port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.ptg-vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  } 
}

resource "aws_lb_listener_rule" "ptg-alb-listener" {
  listener_arn =   aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ptg-tg.arn
  }
}