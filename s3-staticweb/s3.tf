resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.bucketname
  force_destroy = true

  tags = {
    name = "${var.bucketname}_website"
  }
}

resource "aws_s3_bucket_acl" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# resource "aws_kms_key" "kms_key" {
#   tags = {
#     name = "${var.bucketname}_kms_key"
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket" {
#   bucket = aws_s3_bucket.s3_bucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm     = "aws:kms"
#       kms_master_key_id = aws_kms_key.kms_key.arn
#     }
#   }
# }

resource "aws_s3_object" "object" {
  for_each = fileset(path.module, "staticweb/**/*")
  bucket = aws_s3_bucket.s3_bucket.id
  key    = replace(each.value, "staticweb", "")
  source = each.value
  etag         = filemd5("${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}

resource "aws_s3_bucket_website_configuration" "nghi_web" {
  bucket = aws_s3_bucket.s3_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = templatefile("s3-policy.json", { bucket = var.bucketname })
}