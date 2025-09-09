# Toltek Data Stack

A modern ELT data stack built on Google Cloud Platform with containerized pipelines and multi-environment deployment.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Data Sources  │    │   Cloud Run     │    │    BigQuery     │
│                 │───▶│                 │───▶│                 │
│ • Google Sheets │    │ • dlt pipelines │    │ • Raw data      │
│ • REST APIs     │    │ • Orchestration │    │ • dbt models    │
│ • Cloud Storage │    │                 │    │ • Analytics     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Core Components:**
- **Extraction**: [dlt](https://dlthub.com/) pipelines for data ingestion from various sources
- **Transformation**: dbt models for data transformations in BigQuery
- **Infrastructure**: Terraform modules for reproducible GCP resource management

## Project Structure

```
toltek-data-stack/
├── src/
│   └── toltek/
│       ├── extraction/          # dlt pipelines and data sources
│       │   ├── sources/         # Source configurations
│       │   └── pipelines/       # Pipeline implementations
│       └── transformation/      # dbt models and tests
│           ├── models/          # SQL transformations
│           │   ├── staging/     # Staging models
│           │   └── marts/       # Business logic models
│           ├── macros/          # dbt macros
│           └── seeds/           # Static data files
├── terraform/
│   └── modules/                 # Reusable infrastructure components
├── _deployment/                 # CI/CD and deployment configurations
└── infrastructure/              # Infrastructure configurations
```

## Infrastructure Components

**Google Cloud Resources:**
- **BigQuery**: Data warehouse with datasets for raw, staging, and mart layers
- **Cloud Run**: Serverless containers for API and pipeline execution
- **Cloud Storage**: Artifact storage and pipeline state management
- **Cloud Scheduler**: Automated pipeline triggers and job scheduling
- **Artifact Registry**: Private Docker image repository
- **IAM**: Service accounts with principle of least privilege

**Multi-Environment Setup:**
- **Datalake Development** (`-dev`): Development data ingestion and processing
- **Datalake Production** (`-prd`): Production data ingestion and processing  
- **Data Warehouse** (`toltek-dwh-prd`): Centralized BigQuery for dbt transformations and analytics

**Resource Naming Convention:**
- Development: `toltek-{resource}-dev`
- Production: `toltek-{resource}-prd`

## Data Pipeline Flow

1. **Ingestion**: dlt pipelines extract data from configured sources in datalake projects
2. **Loading**: Raw data loaded into BigQuery datasets in respective datalake environments
3. **Cross-project Transfer**: Data transferred from datalake to central warehouse project
4. **Transformation**: dbt models in warehouse project create cleaned and aggregated data marts
5. **Monitoring**: Built-in logging and alerting for pipeline health

## Code Organization

**Extraction Layer** (`src/toltek/extraction/`):
- Source connectors for APIs, databases, and file systems
- Incremental loading strategies and state management
- Data validation and schema inference

**Transformation Layer** (`src/toltek/transformation/`):
- Staging models for data cleaning and standardization
- Mart models for business logic and aggregations
- Tests for data quality and consistency


**Infrastructure Layer** (`terraform/`):
- Modular Terraform configurations for GCP resources
- Reusable modules for common infrastructure patterns

## Development Workflow

The stack supports a complete development lifecycle with separate environments for testing and production deployment. All infrastructure and application code is version controlled and deployed through automated CI/CD pipelines.

---

*Contact the data team for customizations and support.*