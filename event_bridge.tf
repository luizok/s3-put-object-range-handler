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

resource "aws_cloudwatch_event_target" "on_filed_created_target" {
  arn      = aws_sfn_state_machine.on_file_created_handler.arn
  rule     = aws_cloudwatch_event_rule.on_file_created.name
  role_arn = aws_iam_role.on_file_created_target.arn

  input_transformer {
    input_paths = {
      bucket = "$.detail.bucket.name",
      key    = "$.detail.object.key"
    }
    input_template = <<EOF
    {
      "bucket": <bucket>,
      "key":  <key>
    }
    EOF
  }
}
