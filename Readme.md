# MedinSight

MedinSight is a medical analytics and retrieval-augmented generation (RAG)
prototype for exploring clinical cases, laboratory results, and diabetes-related
risk indicators. It combines a reproducible data engineering pipeline with a
multi-tool AI agent:

- structured patient and cohort analytics are modeled in BigQuery with dbt;
- unstructured clinical guidance is loaded from a PDF and indexed with Chroma;
- LangGraph routes user questions to the appropriate BigQuery or document-search
  tool.

The project is intended to help analysts and clinical researchers investigate
patient records and population-level trends from one conversational interface.
It is a decision-support and analytics prototype, not a diagnostic system. Its
responses must be reviewed by a qualified professional and must not replace
clinical judgment.

## Technology stack

- **Docker & Python** - local environment setup, dependency isolation, and
  orchestration of the agent and data pipeline.
- **BigQuery Sandbox** - cloud data warehousing for the raw VitalDB clinical and
  laboratory tables and transformed analytical datasets.
- **dbt & SQL** - staged source models, laboratory pivoting, joins, derived
  glucose/diabetes risk categories, clinical status indicators, and cohort
  summary marts.
- **LangGraph & RAG** - a stateful multi-tool agent that combines structured
  database queries with semantic search over uploaded clinical guidelines.
- **Google Gemini** - language-model reasoning and embedding generation for the
  agent and document retrieval.
- **Chroma** - local vector storage for PDF chunks and their embeddings.

## How it serves users

MedinSight addresses a common gap in healthcare analytics: patient data is
structured and queryable, while clinical guidance is usually stored as
unstructured documents. The application brings both sources together:

1. A user asks about a patient, a laboratory result, a risk category, or an
   aggregate statistic.
2. The LangGraph agent selects a tool based on the question.
3. BigQuery tools retrieve patient-level or population-level metrics from the
   `vitaldb_transformed` dataset.
4. The RAG tool retrieves relevant passages from `data/dc26sint.pdf`.
5. The agent presents the database evidence alongside relevant guideline
   context, making exploration faster and reducing the need to manually switch
   between SQL and reference documents.

This design supports use cases such as:

- checking a case's glucose value and derived diabetes-risk category;
- reviewing associated laboratory measurements;
- comparing age and sex cohorts;
- measuring the number of patients outside the normal glucose range; and
- retrieving guideline passages relevant to a clinical question.

## Architecture

```text
VitalDB API
   |
   v
pipelines/ingest.py  -->  data/*.csv  -->  pipelines/load_data.py
                                                    |
                                                    v
                                      BigQuery raw dataset: vitaldb
                                                    |
                                                    v
                              dbt staging and intermediate models
                                                    |
                                                    v
                       BigQuery marts: vitaldb_transformed
                                                    |
                         +--------------------------+
                         |                          |
                         v                          v
              LangGraph BigQuery tools       Gemini embeddings
                                                    |
                                      PDF --> Chroma vector store
                         \                          /
                          +------ LangGraph agent -+
```

### Data pipeline

`main.py` downloads the VitalDB `cases` and `labs` endpoints, writes them to
the `data/` directory, and loads them into the `vitaldb` BigQuery dataset.
The dbt project in `dbt_medinsights/` then:

- exposes the raw tables through staging models;
- pivots laboratory rows into case-level columns;
- joins clinical and laboratory data;
- derives glucose-based diabetes risk and overall clinical status; and
- creates patient and cohort summary marts.

The agent queries the transformed
`vitaldb_transformed.fct_patient_clinical_summary` mart and calculates
high-level summary statistics from the same dataset.

### AI and retrieval pipeline

`agent/medical_agent.py` loads the clinical PDF, creates Gemini embeddings, and
stores the resulting vectors in a local Chroma database. It registers three
agent tools:

- `query_patient_marts` for custom BigQuery queries;
- `get_dataset_summary_stats` for aggregate hospital statistics; and
- `medical_guideline_search` for semantic search over the uploaded PDF.

## Project structure

```text
.
├── agent/
│   └── medical_agent.py       # LangGraph agent and retrieval tools
├── data/
│   ├── clinical_data.csv      # Downloaded clinical cases
│   ├── lab_data.csv           # Downloaded laboratory results
│   └── dc26sint.pdf           # Clinical guidance source document
├── dbt_medinsights/
│   ├── dbt_project.yml
│   ├── models/
│   │   ├── staging/           # Raw source references
│   │   ├── intermediate/      # Case-level lab transformations
│   │   └── mart/              # Analytical outputs
├── pipelines/
│   ├── ingest.py              # VitalDB API extraction
│   └── load_data.py           # BigQuery loading
├── main.py                    # ETL entry point
├── Dockerfile
├── docker-compose.yml
└── requirements.txt
```

## Prerequisites

- Python 3.11 or newer
- A Google Cloud project with BigQuery enabled
- Application Default Credentials for BigQuery, for example:

  ```powershell
  gcloud auth application-default login
  ```

- A Gemini API key
- Docker Desktop, if using the container workflow

The examples below use Windows PowerShell from the repository root.

## Local setup

Create and activate the virtual environment:

```powershell
python -m venv MedinSight
.\MedinSight\Scripts\Activate.ps1
pip install -r requirements.txt
```

Create a `.env` file in the project root:

```dotenv
GEMINI_API_KEY=your-gemini-api-key
```

Do not commit `.env` or credentials to source control.

## Running the data pipeline

Download the VitalDB source data and load the raw tables into BigQuery:

```powershell
python .\main.py
```

Run dbt from its project directory:

```powershell
cd .\dbt_medinsights
dbt debug
dbt build
cd ..
```

The dbt profile must be configured for the `medinsights` target and the
BigQuery project/dataset used by the environment. The raw source tables are
expected in the `vitaldb` dataset; transformed models are built in the
`vitaldb_transformed` dataset.

## Running the medical agent

Run the script using its path under the `agent` directory:

```powershell
python .\agent\medical_agent.py
```

Running `python medical_agent.py` from the repository root will fail because
that file is not located at the root.

The agent expects:

- `GEMINI_API_KEY` in the environment or `.env`;
- valid Google Cloud credentials for BigQuery;
- `data/dc26sint.pdf`; and
- the transformed dbt mart to exist in BigQuery.

The first run creates a local Chroma persistence directory. It may call the
Gemini embedding service while indexing the PDF.

## Running with Docker Compose

After configuring Google Cloud credentials and the required environment
variables, build and start the service:

```powershell
docker compose up --build
```

The compose configuration mounts the repository at `/workspace` and starts
`agent/medical_agent.py`. Cloud authentication must also be made available to
the container using the credential mechanism configured for the deployment
environment.

## Configuration notes

The current prototype contains project and dataset identifiers in the Python
pipeline and agent code. For shared, production, or multi-environment use,
move these values to environment variables or a typed configuration file.
Keep API keys, service-account files, and other credentials outside the
repository.

## Limitations and responsible use

- The derived risk categories are rule-based analytics, not diagnoses.
- The quality of agent answers depends on the source data, dbt build status,
  retrieved document passages, and model output.
- BigQuery SQL access should be constrained and validated before exposing the
  agent to untrusted users.
- Clinical guidance can change; refresh the source documents and re-index the
  vector store when guidance is updated.
- Do not use this prototype as the sole basis for patient care or treatment.