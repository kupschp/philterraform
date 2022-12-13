output "ptg_dynamodb_tflocks" {
  description = "Dynamodb table created for storing terraform lock files"
  value = aws_dynamodb_table.terraform_locks.name
}