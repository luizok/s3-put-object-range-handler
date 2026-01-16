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
    "--INPUT_PATH"                       = ""
    "--OUTPUT_DB"                        = ""
    "--OUTPUT_TABLE"                     = ""
    "--CONTEXT_ID"                       = ""
  }

  timeout = 60 # min
}

resource "aws_glue_catalog_database" "database" {
  name = "${var.project-name}-database"
}

locals {
  partition_keys = ["ano", "mes", "dia"]
  tables = {
    document_a = {
      path = "A/"
      columns = [
        { name = "user_id", type = "string" },
        { name = "value", type = "float" },
        { name = "context_id", type = "string" },
      ]
    },
    document_b = {
      path = "B/"
      columns = [
        { name = "source_id", type = "string" },
        { name = "target_id", type = "string" },
        { name = "value", type = "float" },
        { name = "is_scheduled", type = "boolean" },
        { name = "context_id", type = "string" },
      ]
    },
  }
}

resource "aws_glue_catalog_table" "document_tables" {
  for_each      = local.tables
  name          = each.key
  database_name = aws_glue_catalog_database.database.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
    classification        = "parquet"
    useGlueParquetWriter  = "true"
  }

  dynamic "partition_keys" {
    for_each = local.partition_keys
    content {
      name = partition_keys.value
      type = "int"
    }
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.processed_data_bucket.id}/${each.value.path}"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }

    dynamic "columns" {
      for_each = each.value.columns
      content {
        name = columns.value.name
        type = columns.value.type
      }
    }
  }
}
