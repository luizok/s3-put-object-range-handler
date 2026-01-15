resource "aws_glue_job" "process_data" {
  name     = "${var.project-name}-process-data"
  role_arn = aws_iam_role.glue_process_data.arn

  glue_version      = "5.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  execution_property {
    max_concurrent_runs = 3
  }

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_object.process_data.bucket}/${aws_s3_object.process_data.key}"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://${aws_s3_bucket.glue_scripts.id}/spark-logs/"
    "--TempDir"                          = "s3://${aws_s3_bucket.glue_scripts.id}/temp/"
    "--REF_DATE"                         = ""
    "--DOC_TYPE"                         = ""
    "--FILE_PATH"                        = ""
    "--CONTEXT_ID"                       = ""
  }

  max_retries = 1
  timeout     = 60 # min
}