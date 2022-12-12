#create dynamodb for terraform lock - a nosql key:value storage
resource "aws_dynamodb_table" "terraform_locks" {
  name = "ptg-tflocks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}