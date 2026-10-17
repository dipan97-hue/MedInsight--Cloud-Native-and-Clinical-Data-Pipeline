from pathlib import Path
import requests

## Configuration

url1 = "https://api.vitaldb.net/cases"
url2 = "https://api.vitaldb.net/labs"

Output_dir = Path('data')
clinical_data_path = Output_dir / 'clinical_data.csv'
lab_data_path = Output_dir / 'lab_data.csv'

def clinical_data():
    """
    Download clinical data from vitlab
    """

    response = requests.get(url1, timeout=30)
    response.raise_for_status()

    Output_dir.mkdir(parents=True, exist_ok=True)

    ## Save the data to a CSV file
    clinical_data_path.write_bytes(response.content)

    print(f"Clinical data downloaded and saved to {clinical_data_path}")

## For Lab Data

def lab_data():
    """
    Download clinical data from vitlab
    """

    response = requests.get(url2, timeout=30)
    response.raise_for_status()

    Output_dir.mkdir(parents=True, exist_ok=True)

    ## Save the data to a CSV file
    lab_data_path.write_bytes(response.content)

    print(f"Clinical data downloaded and saved to {lab_data_path}")



