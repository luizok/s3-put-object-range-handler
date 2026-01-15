import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql import functions as F


def decode(layout):

    cols = [
        F.substring(F.col("value"), start, size).alias(name)
        for name, start, size in layout
    ]

    return cols


def decode_document_type_A():
    layout = [
        ("userId", 1, 12),
        ("value", 13, 7),
    ]

    return decode(layout)


def decode_document_type_B():

    layout = [
        ('sourceId', 1, 12),
        ('targetId', 13, 12),
        ('value', 25, 7),
        ('isScheduled', 32, 1)
    ]

    return decode(layout)


DECODE_FUNC_MAP = {
    'A': decode_document_type_A,
    'B': decode_document_type_B,
}

args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "REF_DATE",
        "DOC_TYPE",
        "CONTEXT_ID",
        "INPUT_PATH",
        "OUTPUT_PATH"
    ]
)

job_name = args["JOB_NAME"]
document_type = args["DOC_TYPE"]
ref_date = args["REF_DATE"]
input_path = args["INPUT_PATH"]
output_path = args["OUTPUT_PATH"]

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(job_name, args)


decode_func = DECODE_FUNC_MAP.get(document_type, '')
if not decode_func:
    sys.exit(f'Unknown document type {document_type}')

raw_df = spark.read.text(input_path)
raw_df.show(truncate=False)
df = raw_df.select(*decode_func())
df = df.withColumn("ano", F.lit(ref_date[:4])) \
    .withColumn("mes", F.lit(ref_date[5:7])) \
    .withColumn("dia", F.lit(ref_date[8:])) \
    .withColumn("documentType", F.lit(document_type))

df.show(truncate=False)
dyf = DynamicFrame.fromDF(df, glueContext, "dyf_saida")
glueContext.write_dynamic_frame.from_options(
    frame=dyf,
    connection_type="s3",
    connection_options={
        "path": output_path,
        "partitionKeys": ["ano", "mes", "dia", "documentType"],
    },
    format="parquet",
    format_options={"compression": "snappy"}
)

# TODO
# glueContext.write_dynamic_frame.from_options(
#     frame=source_data,
#     connection_type="s3",
#     connection_options={
#         "path": output_path,
#         "partitionKeys": ["year", "month", "day"], # Specify the columns to partition by
#         "enableUpdateCatalog": True, # Automatically updates the Glue Data Catalog
#         "database": db_name,
#         "table": tbl_name
#     },
#     format="glueparquet", # Use 'glueparquet' for schema handling and performance
#     format_options={"compression": "snappy"}
# )

job.commit()
