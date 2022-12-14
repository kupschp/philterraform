#locals in terraform are aka private variables in proglang linguo, 
#so this module's local vars are only within the scope inside the module can't be changed/called outside of this module
locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  http_protocol = "HTTP"
  all_ips = ["0.0.0.0/0"]
  instance_listen_port = 8080
}