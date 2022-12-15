output "address" {
  value = module.database_instance.address
  description = "database endpoint address"
}

output "port" {
  value = module.database_instance.port
  description = "database listening port"
}