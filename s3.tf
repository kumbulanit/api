resource "aws_s3_bucket" "ingest_bucket" {
  bucket = "sandbox-event-ingest-new"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}