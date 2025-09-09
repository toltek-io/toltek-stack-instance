# Toltek Data Stack - Deployment

## Quick Start

```bash
# 1. Setup (run once)
make create-projects
make check-billing && make link-billing
make bootstrap ENV=dev
make bootstrap ENV=prd

# 2. Deploy
make deploy-infra ENV=dev
make deploy-infra ENV=prd
```

Push to `main`/`develop` → GitHub Actions handles app deployment

## Commands

```bash
make help                    # Show all commands
make setup-help             # Detailed setup instructions
make deploy-help            # Deployment commands

# Core operations
make plan ENV=dev           # Preview changes
make deploy-infra ENV=dev   # Deploy infrastructure
make pipeline ENV=dev       # Run data pipeline
make logs ENV=dev           # View logs
```

## GitHub Actions Setup

Add repository secrets:
- `GCP_SERVICE_ACCOUNT_KEY_DEV`: Contents of service account JSON
- `GCP_SERVICE_ACCOUNT_KEY_PRD`: Contents of service account JSON

---
**Project:** Toltek | **Region:** 