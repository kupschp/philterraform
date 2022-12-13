terraform {
  backend "s3" {
    key = "global/dynamodb/terraform.tfstate"
  }
}