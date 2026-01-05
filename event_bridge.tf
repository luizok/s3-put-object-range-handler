resource "aws_cloudwatch_event_rule" "on_file_created" {
  name = "${var.project-name}-on-file-created"

  event_pattern = jsonencode({
    source      = ["aws.s3"],
    detail-type = ["Object Created"],
    detail = {
      bucket = {
        name = [aws_s3_bucket.inbound_bucket.id]
      },
      object = {
        key = [{ "prefix" : "inbound_data/" }]
      }
    }
  })
}
