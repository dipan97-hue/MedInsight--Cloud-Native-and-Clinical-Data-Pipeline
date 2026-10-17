from pipelines.ingest import clinical_data, lab_data
from pipelines.load_data import load_clinical_data, load_lab_data


print("Starting MedinSight ETL pipeline")


# --------------------------------
# Extract
# --------------------------------
clinical_data()
lab_data()

# --------------------------------
# Load
# --------------------------------

load_clinical_data()

load_lab_data()


print("ETL pipeline completed successfully")