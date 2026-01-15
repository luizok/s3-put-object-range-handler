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

resource "aws_s3_bucket" "glue_scripts" {
  bucket = "${var.project-name}-glue-scripts-${local.account_id}-${local.region}"
}

resource "aws_s3_object" "process_data" {
  bucket = aws_s3_bucket.glue_scripts.id
  key    = "scripts/${var.project-name}-process-data.py"
  source = "./glue_process_data.py"
  etag   = filemd5("./glue_process_data.py")
}
