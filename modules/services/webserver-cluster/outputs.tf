#output is aka return of programming linguo, so you can use this result outside of this module based on the results by calling: module.[modulename].[outputname]
output "ptg_alb_dns_name" {
  value = aws_lb.ptg-alb.dns_name
  description = "alb's domain name"
  
}

output "asg_name" {
  value = aws_autoscaling_group.ptg-mig.name
  description = "autoscalign group name"
}

output "alb_security_group_id" {
  value = aws_security_group.ptg-alb-sg.id
  description = "secgroup id attached to application loadbalancer"
}