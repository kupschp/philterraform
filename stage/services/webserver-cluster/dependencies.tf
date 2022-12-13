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