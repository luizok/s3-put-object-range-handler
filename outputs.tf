output "inbound_bucket_name" {
  value = aws_s3_bucket.inbound_bucket.id
}

output "processed_data_bucket_name" {
  value = aws_s3_bucket.processed_data_bucket.id
}
