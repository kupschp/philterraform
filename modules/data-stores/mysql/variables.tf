variable "db_username" {
  description = "database username"
  type = string
  sensitive = true
}

variable "db_password" {
  description = "database password"
  type = string
  sensitive = true
}

variable "db_instance_type" {
  description = "db instance type"
  type = string
}

variable "identifier_prefix" {
  description = "database prefix"
  type = string
}

variable "db_name" {
  description = "database name"
  type = string
}

variable "db_storage_size" {
  description = "database storage size"
  type = number
}