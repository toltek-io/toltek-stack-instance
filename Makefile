# Toltek Data Stack - Operations
.PHONY: help setup-help deploy-help bootstrap deploy destroy plan pipeline clean create-projects check-billing link-billing

# Environment Variables
CLIENT_SLUG := toltek
DATALAKE_PROJECT_ID_DEV := toltek-datalake-prd
DATALAKE_PROJECT_ID_PRD := toltek-datalake-dev
DATAWAREHOUSE_PROJECT_ID := toltek-dwh-prd
REGION := 
ENV ?= dev

# Set project ID based on environment and component
ifeq ($(ENV),prd)
	DATALAKE_PROJECT_ID = $(DATALAKE_PROJECT_ID_PRD)
else
	DATALAKE_PROJECT_ID = $(DATALAKE_PROJECT_ID_DEV)
endif

help: ## Show available operations
	@echo "Toltek Data Stack - Environment: $(ENV)"
	@echo "Projects: $(DATALAKE_PROJECT_ID) | $(DATAWAREHOUSE_PROJECT_ID)"
	@echo ""
	@echo "📋 Main Commands:"
	@echo "  make setup-help           📖 Detailed setup guide"
	@echo "  make deploy-help          🚀 Deployment commands" 
	@echo ""
	@echo "🚀 Quick Start:"
	@echo "  make create-projects      Create GCP projects"
	@echo "  make bootstrap ENV=dev    Initialize environment"
	@echo "  make deploy-infra ENV=dev Deploy infrastructure"
	@echo ""
	@echo "⚡ Operations:"
	@echo "  make pipeline ENV=dev     Run data pipeline"
	@echo "  make logs ENV=dev         View logs"
	@echo "  make status ENV=dev       Check services"

setup-help: ## Show detailed setup instructions
	@echo "🔧 Toltek Data Stack - Setup Guide"
	@echo ""
	@echo "1️⃣  Projects & Billing:"
	@echo "   make create-projects      # Create GCP projects"
	@echo "   make check-billing        # Verify billing"
	@echo "   make link-billing         # Link billing"
	@echo ""
	@echo "2️⃣  Environment Setup:"
	@echo "   make bootstrap ENV=dev    # Initialize dev"
	@echo "   make bootstrap ENV=prd    # Initialize prod"
	@echo ""
	@echo "3️⃣  Deploy Infrastructure:"
	@echo "   make deploy-infra ENV=dev # Deploy to dev"
	@echo "   make deploy-infra ENV=prd # Deploy to prod"
	@echo ""
	@echo "✅ Push to GitHub → App auto-deploys"

deploy-help: ## Show deployment and runtime help  
	@echo "🚀 Toltek Data Stack - Operations"
	@echo ""
	@echo "🏗️  Infrastructure:"
	@echo "   make plan ENV=dev         # Preview changes"
	@echo "   make deploy-infra ENV=dev # Deploy infrastructure"
	@echo "   make destroy ENV=dev      # ⚠️  Destroy resources"
	@echo ""
	@echo "⚡ Data Pipeline:"
	@echo "   make pipeline ENV=dev     # Run full pipeline"
	@echo "   make extract ENV=dev      # Extract only"
	@echo "   make transform ENV=dev    # Transform only"
	@echo ""
	@echo "🔍 Monitoring:"
	@echo "   make logs ENV=dev         # View logs"
	@echo "   make status ENV=dev       # Check status"
	@echo "   make health ENV=dev       # Health check"
	@echo ""
	@echo "🛠️  Development:"
	@echo "   make dev                  # Run API locally"
	@echo "   make lint                 # Check code"
	@echo "   make format               # Format code"

##############################################################################
# 🔧 SETUP OPERATIONS (Run once during initial setup)
##############################################################################

check-billing: ## Check for active billing accounts
	@echo "Checking for active billing accounts..."
	@BILLING_ACCOUNTS=$$(gcloud billing accounts list --filter="open=true" --format="value(name)" 2>/dev/null | head -1); \
	if [ -z "$$BILLING_ACCOUNTS" ]; then \
		echo "❌ No active billing accounts found."; \
		echo "Please set up billing at: https://console.cloud.google.com/billing"; \
		exit 1; \
	else \
		echo "✅ Found active billing account: $$BILLING_ACCOUNTS"; \
	fi

link-billing: ## Link billing account to all projects
	@echo "Linking billing account to projects..."
	@BILLING_ACCOUNT=$$(gcloud billing accounts list --filter="open=true" --format="value(name)" 2>/dev/null | head -1); \
	if [ -z "$$BILLING_ACCOUNT" ]; then \
		echo "❌ No active billing accounts found. Please run 'make check-billing' first."; \
		exit 1; \
	fi; \
	echo "Using billing account: $$BILLING_ACCOUNT"; \
	echo "Linking to $(DATALAKE_PROJECT_ID_DEV)..."; \
	gcloud billing projects link $(DATALAKE_PROJECT_ID_DEV) --billing-account=$$BILLING_ACCOUNT || true; \
	echo "Linking to $(DATALAKE_PROJECT_ID_PRD)..."; \
	gcloud billing projects link $(DATALAKE_PROJECT_ID_PRD) --billing-account=$$BILLING_ACCOUNT || true; \
	echo "Linking to $(DATAWAREHOUSE_PROJECT_ID)..."; \
	gcloud billing projects link $(DATAWAREHOUSE_PROJECT_ID) --billing-account=$$BILLING_ACCOUNT || true; \
	echo "✅ Billing accounts linked to all projects"

create-projects: ## Create GCP projects (datalake dev/prd and datawarehouse)
	@echo "Creating datalake projects: $(DATALAKE_PROJECT_ID_DEV), $(DATALAKE_PROJECT_ID_PRD)"
	@echo "Creating datawarehouse project: $(DATAWAREHOUSE_PROJECT_ID)"
	gcloud projects create $(DATALAKE_PROJECT_ID_DEV) --name="Toltek Datalake Development"
	gcloud projects create $(DATALAKE_PROJECT_ID_PRD) --name="Toltek Datalake Production"
	gcloud projects create $(DATAWAREHOUSE_PROJECT_ID) --name="Toltek Datawarehouse"
	@echo "✅ Projects created. Next: run 'make link-billing' then 'make bootstrap'"

generate-env: ## Generate environment file for current ENV
	@echo "📝 Generating .env.$(ENV) from template..."
	@sed 's/ENV/$(ENV)/g' _deployment/.env.template.jinja > _deployment/.env.$(ENV)
	@echo "✅ Generated _deployment/.env.$(ENV)"

bootstrap: generate-env ## Bootstrap environment (ENV=dev|prd)
	@echo "🚀 Bootstrapping $(ENV) environment..."
	@echo "🔐 Checking authentication..."
	@gcloud auth application-default print-access-token >/dev/null 2>&1 || (echo "❌ Authentication expired. Run: gcloud auth application-default login" && exit 1)
	uv sync --extra dev
	@echo "🔧 Bootstrapping datalake project: $(DATALAKE_PROJECT_ID)"
	gcloud config set project $(DATALAKE_PROJECT_ID)
	gcloud services enable run.googleapis.com bigquery.googleapis.com storage.googleapis.com secretmanager.googleapis.com artifactregistry.googleapis.com
	gsutil mb -p $(DATALAKE_PROJECT_ID) gs://$(DATALAKE_PROJECT_ID)-terraform-state || true
	gsutil versioning set on gs://$(DATALAKE_PROJECT_ID)-terraform-state
	@echo "🔧 Bootstrapping datawarehouse project: $(DATAWAREHOUSE_PROJECT_ID)"
	gcloud config set project $(DATAWAREHOUSE_PROJECT_ID)
	gcloud services enable bigquery.googleapis.com storage.googleapis.com secretmanager.googleapis.com
	cd terraform/environments/$(ENV) && terragrunt init
	@echo "✅ Bootstrap complete for $(ENV)"

##############################################################################
# 🏗️ INFRASTRUCTURE OPERATIONS  
##############################################################################

plan: ## Plan infrastructure changes
	@echo "Planning $(ENV) infrastructure deployment..."
	cd terraform/environments/$(ENV) && terragrunt plan

deploy-infra: ## Deploy infrastructure (static resources)
	@echo "Deploying infrastructure to $(ENV)..."
	cd terraform/environments/$(ENV) && terragrunt apply -auto-approve
	@echo "✅ Deployed infrastructure to $(ENV)"

deploy-workflows: ## Deploy Google Workflows infrastructure
	@echo "Deploying workflows infrastructure to $(ENV)..."
	cd terraform/environments/$(ENV) && terragrunt apply -auto-approve -target=module.workflows -target=module.cloud_scheduler
	@echo "✅ Deployed workflows infrastructure to $(ENV)"

destroy: ## Destroy infrastructure resources
	@echo "⚠️  WARNING: This will destroy all resources in $(ENV) environment!"
	@echo "Datalake Project: $(DATALAKE_PROJECT_ID)"
	@echo "Datawarehouse Project: $(DATAWAREHOUSE_PROJECT_ID)"
	@read -p "Type '$(ENV)' to confirm destruction: " confirm; \
	if [ "$$confirm" = "$(ENV)" ]; then \
		echo "🗑️  Destroying $(ENV) infrastructure..."; \
		cd terraform/environments/$(ENV) && terragrunt destroy -auto-approve; \
		echo "✅ Infrastructure destroyed in $(ENV)"; \
	else \
		echo "❌ Destruction cancelled"; \
		exit 1; \
	fi

##############################################################################
# ⚡ PIPELINE OPERATIONS (Runtime commands)
##############################################################################

pipeline: ## Run complete data pipeline
	cd src/toltek && uv run python -m extraction.pipelines.main
	cd src/toltek/transformation && dbt build

extract: ## Run data extraction only
	cd src/toltek && uv run python -m extraction.pipelines.main

transform: ## Run dbt transformations only
	cd src/toltek/transformation && dbt build

##############################################################################
# 🐳 DOCKER OPERATIONS (For local development)
##############################################################################

build-image: ## Build Docker image
	@echo "🐳 Building Docker image for $(ENV)..."
	@IMAGE_TAG=$(REGION)-docker.pkg.dev/$(DATALAKE_PROJECT_ID)/docker-repo/$(CLIENT_SLUG)-extraction:latest; \
	docker build -t $$IMAGE_TAG -f infrastructure/docker/Dockerfile .; \
	echo "✅ Built image: $$IMAGE_TAG"

push-image: ## Push Docker image to Artifact Registry  
	@echo "📤 Pushing Docker image for $(ENV)..."
	@gcloud auth configure-docker $(REGION)-docker.pkg.dev --quiet
	@IMAGE_TAG=$(REGION)-docker.pkg.dev/$(DATALAKE_PROJECT_ID)/docker-repo/$(CLIENT_SLUG)-extraction:latest; \
	docker push $$IMAGE_TAG; \
	echo "✅ Pushed image: $$IMAGE_TAG"


##############################################################################  
# 🛠️ DEVELOPMENT OPERATIONS
##############################################################################

dev: ## Run API locally for development
	cd src/toltek && uv run uvicorn api:app --host 0.0.0.0 --port 8080 --reload

lint: ## Run code linting
	cd src/toltek && uv run ruff check . && uv run mypy .

format: ## Format code
	cd src/toltek && uv run black . && uv run isort .

clean: ## Clean build artifacts
	rm -rf __pycache__ .pytest_cache .mypy_cache src/toltek/transformation/target
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete

##############################################################################
# 🔍 MONITORING OPERATIONS
##############################################################################

logs: ## View Cloud Run logs
	gcloud logs read "resource.type=cloud_run_revision" --limit=50 --project=$(DATALAKE_PROJECT_ID)

status: ## Check service status
	gcloud run services list --region=$(REGION) --project=$(DATALAKE_PROJECT_ID)

health: ## Check API health
	@SERVICE_URL=$$(gcloud run services describe $(CLIENT_SLUG)-extraction-$(ENV) --region=$(REGION) --project=$(DATALAKE_PROJECT_ID) --format="value(status.url)" 2>/dev/null); \
	if [ -n "$$SERVICE_URL" ]; then \
		echo "Service URL: $$SERVICE_URL"; \
		curl -f -s "$$SERVICE_URL/health" | jq || echo "❌ Health check failed"; \
	else \
		echo "❌ Service not found"; \
	fi