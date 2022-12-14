output "ptg_alb_name" {
  value = module.webserver_cluster.ptg_alb_dns_name
  description = "generated domain name of application load balancer"
}