resource "aws_s3_bucket" "photogram_image" {
  bucket = "photogram.image"

  tags = {
    Name = "photogram_image"
  }
}

resource "aws_s3_bucket" "photogram_src" {
  bucket = "photogram.src"

  tags = {
    Name = "photogram_src"
  }
}

locals {
  web_files    = ["./webserver/app.js", "./webserver/index.html", "./webserver/package.json"]
  resize_files = ["./resizer/app.js", "./resizer/package.json"]
}

resource "aws_s3_object" "web_files" {
  for_each = { for idx, file in local.web_files : idx => file }

  bucket = aws_s3_bucket.photogram_src.id
  key    = "web/${each.value}"
  source = each.value
}

resource "aws_s3_object" "resize_files" {
  for_each = { for idx, file in local.resize_files : idx => file }

  bucket = aws_s3_bucket.photogram_src.id
  key    = "resize/${each.value}"
  source = each.value
}
