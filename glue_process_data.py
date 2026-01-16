import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql import functions as F, types as T


def decode(layout):

    layout_default_fn = []
    identity_fn = lambda c: c  # noqa:E731
    for col_def in layout:
        if len(col_def) == 3:
            layout_default_fn.append((*col_def, identity_fn))
            continue

        layout_default_fn.append(col_def)

    cols = [
        apply(F.substring(F.col("value"), start, size)).alias(name)
        for name, start, size, apply in layout_default_fn
    ]

    return cols


def decode_document_type_A():
    layout = [
        ('_type', 1, 1),
        ("user_id", 2, 12),
        ("value", 14, 7, lambda c: c.cast(T.FloatType()) / 100),
    ]

    return decode(layout)


def decode_document_type_B():

    layout = [
        ('_type', 1, 1),
        ('source_id', 2, 12),
        ('target_id', 14, 12),
        ('value', 26, 7, lambda c: c.cast(T.FloatType()) / 100),
        ('is_scheduled', 33, 1, lambda c: c == 'T')
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
        "OUTPUT_DB",
        "OUTPUT_TABLE",
    ]
)

job_name = args["JOB_NAME"]
job_run_id = args["JOB_RUN_ID"]
document_type = args["DOC_TYPE"]
context_id = args["CONTEXT_ID"]
ref_date = args["REF_DATE"]
input_path = args["INPUT_PATH"]
output_db = args["OUTPUT_DB"]
output_table = args["OUTPUT_TABLE"]

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
df = raw_df \
    .filter(F.col('value').startswith('1')) \
    .select(*decode_func()) \
    .drop('_type')
df = df.withColumn("ano", F.lit(ref_date[:4])) \
    .withColumn("mes", F.lit(ref_date[5:7])) \
    .withColumn("dia", F.lit(ref_date[8:])) \
    .withColumn("context_id", F.lit(context_id))

df.show(truncate=False)
dyf = DynamicFrame.fromDF(df, glueContext, "dyf_saida")
glueContext.write_dynamic_frame.from_catalog(
    frame=dyf,
    database=output_db,
    table_name=output_table,
    additional_options={
        "enableUpdateCatalog": True,
        "updateBehavior": "UPDATE_IN_DATABASE",
        "partitionKeys": ["ano", "mes", "dia"]
    }
)

job.commit()
