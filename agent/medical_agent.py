import os
from google.cloud import bigquery
from langchain_core.tools import tool
from langchain_community.document_loaders import PyPDFLoader
from langchain_google_genai import ChatGoogleGenerativeAI, GoogleGenerativeAIEmbeddings
from langgraph.prebuilt import create_react_agent
from langchain_community.vectorstores import Chroma
from dotenv import load_dotenv
load_dotenv()



project_id = "medical-analytics-510812"
dataset_id = "vitaldb_transformed"

googleapi_key = os.getenv("GEMINI_API_KEY")
if not googleapi_key:
    raise EnvironmentError(
        "GEMINI_API_KEY is not set. Add it to a .env file or set it in the shell "
        "before running this script."
    )

## Step 1: Create a BigQuery client
bg_client = bigquery.Client(project=project_id)
docs = r'D:\exercises\Projects\MedInsights\data\dc26sint.pdf'

if not os.path.exists(docs):
    raise FileNotFoundError(f"The file {docs} does not exist.")
else:
    loader = PyPDFLoader(docs)
    docs = loader.load()
    embeddings = GoogleGenerativeAIEmbeddings(
        model="models/gemini-embedding-001",
        api_key=googleapi_key,
    )
    vectorstore = Chroma.from_documents(docs, embeddings, persist_directory ='./chroma_db')
    retriever = vectorstore.as_retriever(search_kwargs={"k": 3})

@tool
def query_patient_marts(sql_query: str) -> str:
    """Executes a custom SQL query on BigQuery transformed medical marts (vitaldb_transformed.fct_patient_clinical_summary) to fetch patient demographics, lab values, and derived diabetes risk categories."""
    try:
        query_job = bg_client.query(sql_query)
        results = query_job.result()
        rows = [dict(row) for row in results]
        return str(rows)
    except Exception as e:
        return f"Error executing query: {str(e)}"

@tool
def medical_guideline_search(query: str) -> str:
    """Useful for searching official clinical treatment guidelines, diabetes management protocols, and medical procedures from uploaded PDFs."""
    if not retriever:
        return "No clinical guidelines PDF is currently loaded."
    retrieved_docs = retriever.invoke(query)
    return str([doc.page_content for doc in retrieved_docs])

@tool
def get_dataset_summary_stats() -> str:
    """Fetches high-level aggregate hospital statistics across the entire VitalDB transformed mart dataset."""
    query = f"""
        select 
            count(distinct case_id) as total_patients,
            round(avg(patient_age), 1) as average_age,
            countif(diabetes_risk_category != 'Normal Glucose Range') as total_at_risk_patients
        from `{project_id}.{dataset_id}.fct_patient_clinical_summary`
    """
    try:
        query_job = bg_client.query(query)
        results = [dict(row) for row in query_job.result()]
        return str(results)
    except Exception as e:
        return f"Error fetching summary stats: {str(e)}"

# Register all tools into the agent toolbelt
tools = [query_patient_marts, medical_guideline_search, get_dataset_summary_stats]

# ==========================================
# 3. INITIALIZE LANGGRAPH REACT AGENT
# ==========================================
llm = ChatGoogleGenerativeAI(model="gemini-3.1-pro-preview", temperature=0)

# Compile the modern graph-based ReAct agent executor
agent_executor = create_react_agent(llm, tools=tools)

# ==========================================
# 4. EXECUTE TEST INVOCATION
# ==========================================
if __name__ == "__main__":
    query = "Check the patient record for case ID 1 from BigQuery to see their glucose and diabetes risk category, and then look up what our clinical guidelines recommend for that condition."
    print(f"\n--- Running LangGraph Agent Query: {query} ---\n")
    
    # LangGraph invocation payload format
    inputs = {"messages": [("user", query)]}
    response = agent_executor.invoke(inputs)
    
    print("\n--- Agent Final Response ---\n")
    print(response["messages"][-1].content)
