resource "aws_s3_bucket" "inbound_bucket" {
  bucket = "${var.project-name}-inbound-bucket-${data.aws_caller_identity.current}-${data.aws_region.current}"
}

resource "aws_s3_bucket" "processed_data_bucket" {
  bucket = "${var.project-name}-processed_bucket-${data.aws_caller_identity.current}-${data.aws_region.current}"
}

resource "aws_s3_bucket_notification" "on_file_created" {
  bucket      = aws_s3_bucket.inbound_bucket.id
  eventbridge = true
}
