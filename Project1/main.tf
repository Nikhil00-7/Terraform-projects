
# creating s3  bucket
resource "aws_s3_bucket" "firstbucket" {
    bucket= var.first_bucket_name
}

# making s3 bucket private
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.firstbucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#  adding s3 bucket  policies
  resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = aws_s3_bucket.firstbucket.id
  depends_on = [ aws_s3_bucket_public_access_block.block]
  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"

        Principal = {
          Service = "cloudfront.amazonaws.com"
        }

        Action = ["s3:GetObject"]

        Resource = "${aws_s3_bucket.firstbucket.arn}/*"

        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}


 resource "aws_s3_bucket_versioning" "first_bucket_versioning" {
        bucket = aws_s3_bucket.firstbucket.id

      versioning_configuration {
        status = "Enabled"
      }
 }

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
     bucket =  aws_s3_bucket.firstbucket.id
     rule {
        apply_server_side_encryption_by_default {
           kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
        }
     }
}


# making the  access of the bucket 
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "demo_oac"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_s3_object" "object" {
  depends_on = [ aws_s3_bucket_versioning.first_bucket_versioning ]
  bucket = aws_s3_bucket.firstbucket.id
  for_each =  fileset("${path.module}/www","**/*")
  key    = each.value
  source =  "${path.module}/www/${each.value}"

  etag = filemd5("${path.module}/www/${each.value}" )

    content_type = lookup(
    {
      html = "text/html"
      css  = "text/css"
      js   = "application/javascript"
      json = "application/json"
      png  = "image/png"
      jpg  = "image/jpeg"
      jpeg = "image/jpeg"
      svg  = "image/svg+xml"
      ico  = "image/x-icon"
      txt  = "text/plain"
    },
    regex("\\.([^.]+)$", each.value)[0],
    "application/octet-stream"
  )
}



resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.firstbucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = local.origin_id 
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"


  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

    price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

aliases = ["nikhil.com"]
  viewer_certificate {
     acm_certificate_arn = aws_acm_certificate.dev_certificate.arn
     ssl_support_method = "sni-only"
  }

  depends_on = [
    aws_acm_certificate_validation.arn_valid
  ]
}


resource "aws_route53_zone" "main" {
    name= "nikhil.com"
}


resource "aws_acm_certificate" "dev_certificate" {
    provider          = aws.use1
    domain_name = "nikhil.com"
    validation_method = "DNS"

    lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "dev_ns" {
  for_each = {
    for dvo in aws_acm_certificate.dev_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}



resource "aws_acm_certificate_validation" "arn_val  id" {
   certificate_arn         = aws_acm_certificate.dev_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.dev_ns : record.fqdn]
}
