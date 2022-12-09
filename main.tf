provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example" {
  ami = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"

  tags = {
    Name = "ptg-instance"
  }

  #user_data is a boot startup script in ec2(virtual machienes) terminology for aws
  user_data = <<-EOF
              #!/bin/bash
              echo "Philtest hello!" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  #termiantes and creates new instance once startup script(user_data) has been changed
  user_data_replace_on_change = true
}

resource "aws_security_group" "instance" {
  name = "ptg-allow-web-traffic"

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}
