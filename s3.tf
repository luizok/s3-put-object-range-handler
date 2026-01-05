resource "aws_s3_bucket" "inbound_bucket" {
  bucket = "${var.project-name}-inbound-${local.account_id}-${local.region}"
}

resource "aws_s3_bucket" "processed_data_bucket" {
  bucket = "${var.project-name}-processed-${local.account_id}-${local.region}"
}

resource "aws_s3_bucket_notification" "on_file_created" {
  bucket      = aws_s3_bucket.inbound_bucket.id
  eventbridge = true
}
