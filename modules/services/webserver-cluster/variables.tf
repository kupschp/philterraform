#aka programming lingo: variables (input paramaters) for revoking this modules (function)
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

variable "cluster_name" {
  description = "cluster name for all resources"
  type = string
}

variable "db_remote_state_key" {
  description = "obejct storage path of database_s tfstate"
  type = string
}

variable "db_remote_state_bucket" {
  description = "bucket name"
  type = string
}

variable "instance_type" {
  description = "machine type of the instance"
  type = string
}

variable "instance_image" {
  description = "image to be used for the instance"
  type = string
  default = "ami-0fb653ca2d3203ac1"
}

variable "cluster_min_size" {
  description = "minimum number of instances in a cluster"
  type = number
}

variable "cluster_max_size" {
  description = "maximum number of instances in a cluster"
  type = number
}