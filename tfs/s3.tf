# Create general purpose S3 bucket "photogram-s3-src"
resource "aws_s3_bucket" "photogram_s3_src" {
  bucket = "photogram-s3-src"
  acl    = "private"

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "photogram-s3-src"
  }
}

# Create folders in the "photogram-s3-src" bucket
resource "aws_s3_object" "resize_folder" {
  bucket = aws_s3_bucket.photogram_s3_src.id
  key    = "resize/"
  acl    = "private"
}

resource "aws_s3_object" "web_folder" {
  bucket = aws_s3_bucket.photogram_s3_src.id
  key    = "web/"
  acl    = "private"
}

# Create S3 bucket "photogram-s3-image"
resource "aws_s3_bucket" "photogram_s3_image" {
  bucket = "photogram-s3-image"
  acl    = "private"

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "photogram-s3-image"
  }
}
