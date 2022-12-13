variable "ptg-web-port" {
  description = "Port to listen and allow for web traffic"
  type        = number
  default     = 8080
}

variable "region" {
  description = "default region for resources s3 (object storage), ec2 (vm), rds (db)"
  type = string
  default = "us-east-2"
}

variable "bucket" {
  description = "default bucket to use as backend and fetch db tf state for username and password"
  type = string
  default = "ptg-tfstate"
}

variable "ptg_db_tfstate_path" {
  description = "obejct storage path of database_s tfstate"
  type = string
  default = "stage/data-stores/mysql/terraform.tfstate"
}