variable "ptg_db_username" {
  description = "database username"
  type = string
  sensitive = true
}

variable "ptg_db_password" {
  description = "database password"
  type = string
  sensitive = true
}

variable "db_instance_type" {
  description = "db instance type"
  type = string
}