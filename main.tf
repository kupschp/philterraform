provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "ptg-instance" {
  ami = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ptg-allow-web-traffic.id]

  tags = {
    Name = "ptg-instance"
  }

  #user_data is a boot startup script in ec2(virtual machienes) terminology for aws
  user_data = <<-EOF
              #!/bin/bash
              echo "Philtest hello!" > index.html
              nohup busybox httpd -f -p ${var.ptg-web-port} &
              EOF

  #termiantes and creates new instance once startup script(user_data) has been changed
  user_data_replace_on_change = true
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

output "ptg-generated-public-ip" {
  description = "ephemeral public ip generated from ptginstance"
  value       = aws_instance.ptg-instance.public_ip
}
