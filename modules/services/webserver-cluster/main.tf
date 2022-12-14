#image used for vm cluster
resource "aws_launch_configuration" "ptg-image-template" {
  image_id        = var.instance_image
  instance_type   = var.instance_type
  security_groups = [aws_security_group.ptg-allow-web-traffic.id]

  #user_data is a boot startup script in ec2(virtual machienes) terminology for aws
  user_data = templatefile("${path.module}/dumb-web.sh", {
    server_port = var.ptg-web-port
    db_address = data.terraform_remote_state.db.outputs.address
    db_port = data.terraform_remote_state.db.outputs.port
  })

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

  min_size = var.cluster_min_size
  max_size = var.cluster_max_size
  
  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }
}

resource "aws_security_group" "ptg-allow-web-traffic" {
  name = "${var.cluster_name}-allow-web-traffic"

  ingress {
    from_port = local.instance_listen_port
    to_port   = local.instance_listen_port
    protocol  = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
}

resource "aws_security_group" "ptg-alb-sg" {
   name = "${var.cluster_name}-alb-sg"
}

#previously, it was inline igress{} and egress{} block inside of ptg-alb-sg resource, disadvantage unreusable
#separate these ingress and egress block into it_s own resource block for reusability by returning output in-order for anyone who revokes this module to reuse the value returned
resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.ptg-alb-sg.id

  from_port = local.http_port
  to_port   = local.http_port
  protocol  = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_http_outbound" {
  type = "egress"
  security_group_id = aws_security_group.ptg-alb-sg.id

  from_port = local.http_port
  to_port   = local.http_port
  protocol  = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_lb" "ptg-alb" {
  name               = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.ptg-subnets.ids
  security_groups = [aws_security_group.ptg-alb-sg.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ptg-alb.arn
  port              = local.http_port
  protocol          = local.http_protocol

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

resource "aws_lb_target_group" "ptg-tg" {
  name     = "${var.cluster_name}-tg"
  port     = local.instance_listen_port
  protocol = local.http_protocol
  vpc_id   = data.aws_vpc.ptg-vpc.id

  health_check {
    path                = "/"
    protocol            = local.http_protocol
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