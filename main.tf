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

variable "ptg-web-port" {
  description = "Port to listen and allow for web traffic"
  type        = number
  default     = 8080
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
