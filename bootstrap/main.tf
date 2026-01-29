# bootstrap/main.tf
provider "aws" {
  region = "us-east-1"
}

# יצירת ה-Bucket לשמירת ה-State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "ben-state-project6" 
  
  lifecycle {
    prevent_destroy = true # מגן מפני מחיקה בטעות
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# יצירת הטבלה לנעילות
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "ben-devops-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}