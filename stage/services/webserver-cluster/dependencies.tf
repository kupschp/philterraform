#data is used to query provider api, for this example it's to get the default vpc
data "aws_vpc" "ptg-vpc" {
  default = true
}

data "aws_subnets" "ptg-subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.ptg-vpc.id] 
  }
}

#read tfstate file of db in backend object storage s3
data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.bucket
    key = var.ptg_db_tfstate_path
    region = var.region
   }
}