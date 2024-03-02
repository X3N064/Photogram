resource "aws_route53_zone" "photogram_zone" {
  name = "0x0.kr"
}

resource "aws_route53_record" "photogram_alias" {
  zone_id = aws_route53_zone.photogram_zone.zone_id
  name    = "photogram.0x0.kr"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.photogram_CF.domain_name
    zone_id                = aws_cloudfront_distribution.photogram_CF.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "photogram_image_alias" {
  zone_id = aws_route53_zone.photogram_zone.zone_id
  name    = "photogram-image.0x0.kr"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.photogram_image_CF.domain_name
    zone_id                = aws_cloudfront_distribution.photogram_image_CF.hosted_zone_id
    evaluate_target_health = false
  }
}
