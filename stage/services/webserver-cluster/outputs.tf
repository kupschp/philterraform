output "ptg_alb_dns_name" {
  value = aws_lb.ptg-alb.dns_name
  description = "alb's domain name"
  
}