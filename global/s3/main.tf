terraform {
  backend "s3" {
    key = "global/s3/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-2"
}


#create bucket and disable deletion
resource "aws_s3_bucket" "terraform_state" {
  bucket = "ptg-tfstate"

  lifecycle {
    prevent_destroy = true
  }
}

#enable versioning
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

#enable encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#block public access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
