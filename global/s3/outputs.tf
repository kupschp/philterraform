output "ptg_s3_tfstate_storage" {
  description = "Unique ID (ARN) S3 bucket name created for storing terraform state files"
  value = aws_s3_bucket.terraform_state.arn
}