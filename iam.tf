resource "aws_iam_role" "on_file_created_handler" {
  name = "${var.project-name}-sfn-on-file-created-handler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "states.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "on_file_created_handler" {
  name = "${var.project-name}-sfn-on-file-created-handler-policy"
  role = aws_iam_role.on_file_created_handler.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VisualEditor0",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          aws_s3_bucket.inbound_bucket.arn,
          "${aws_s3_bucket.inbound_bucket.arn}/*",
          aws_s3_bucket.processed_data_bucket.arn,
          "${aws_s3_bucket.processed_data_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "on_file_created_target" {
  name = "${var.project-name}-sfn-on-file-created-target-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "on_file_created_target" {
  name = "${var.project-name}-sfn-on-file-created-target-policy"
  role = aws_iam_role.on_file_created_target.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "VisualEditor0",
        Effect   = "Allow",
        Action   = "states:StartExecution",
        Resource = aws_sfn_state_machine.on_file_created_handler.arn
      }
    ]
  })
}
