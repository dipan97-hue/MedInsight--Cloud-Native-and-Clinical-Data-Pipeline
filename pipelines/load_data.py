from pathlib import Path

from google.cloud import bigquery


PROJECT_ID = "medical-analytics-510812"
DATASET_ID = "vitaldb"

BASE_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = BASE_DIR / "data"


def load_csv_to_bigquery(file_name, table_name):

    file_path = DATA_DIR / file_name

    print(f"Loading {file_name} into BigQuery...")

    client = bigquery.Client(project=PROJECT_ID)

    table_id = f"{PROJECT_ID}.{DATASET_ID}.{table_name}"

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,
        autodetect=True,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE
    )

    with open(file_path, "rb") as source_file:

        job = client.load_table_from_file(
            source_file,
            table_id,
            job_config=job_config
        )

    job.result()

    table = client.get_table(table_id)

    print(f"Loaded successfully: {table_id}")
    print(f"Rows loaded: {table.num_rows}")


def load_clinical_data():

    load_csv_to_bigquery(
        "clinical_data.csv",
        "clinical_data"
    )


def load_lab_data():

    load_csv_to_bigquery(
        "lab_data.csv",
        "lab_data"
    )