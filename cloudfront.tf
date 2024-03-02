resource "aws_cloudfront_distribution" "photogram_CF" {
  origin {
    domain_name = aws_elb.photogram_ELB.dns_name
    origin_id   = "photogram_ELB_origin"
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    target_origin_id = "photogram_ELB_origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    cached_methods         = ["GET", "HEAD"]
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = ["photogram.0x0.kr"]

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  default_root_object = "index.html"
}




resource "aws_cloudfront_origin_access_identity" "photogram_oai" {
  comment = "Allows CloudFront to access the S3 bucket"
}

resource "aws_cloudfront_distribution" "photogram_image_CF" {
  origin {
    domain_name = aws_s3_bucket.photogram_image.bucket_regional_domain_name
    origin_id   = "photogram_image_bucket_origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.photogram_oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "photogram_image_bucket_origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = ["photogram-image.0x0.kr"]

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  default_root_object = "index.html"
}