provider "aws" {
  region = var.region
}

provider "random" {}

data "aws_caller_identity" "current" {}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create an S3 bucket
resource "aws_s3_bucket" "scheduled_objects" {
  bucket = "my-scheduled-objects-bucket-${random_string.bucket_suffix.result}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "scheduled_objects_encryption" {
  bucket = aws_s3_bucket.scheduled_objects.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}






