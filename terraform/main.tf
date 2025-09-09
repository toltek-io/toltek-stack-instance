

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  
  backend "gcs" {
    bucket = "-terraform-state"
    prefix = "/"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  client_slug = replace(lower(var.client_name), " ", "-")
  project_id  = var.create_project ? google_project.project[0].project_id : var.project_id
  
  common_labels = {
    client      = local.client_slug
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Create client folder (only in one environment to avoid conflicts)
module "client_folder" {
  count  = var.environment == "dev" && var.create_folder ? 1 : 0
  source = "./modules/folder"
  
  folder_name = var.client_name
  parent_id   = var.organization_id
  
  folder_admins = var.folder_admins
  billing_users = var.billing_users
}

# Create projects under the folder
resource "google_project" "project" {
  count           = var.create_project ? 1 : 0
  name            = "${var.client_name}-${var.environment}"
  project_id      = "${var.project_id}-${var.environment}"
  folder_id       = var.folder_id
  billing_account = var.billing_account_id
  
  labels = local.common_labels
}

# Enable APIs
resource "google_project_service" "apis" {
  for_each = toset(var.required_apis)
  project  = local.project_id
  service  = each.value
}

# Service Account for data pipeline
module "service_account" {
  source = "./modules/service-account"
  
  project_id   = local.project_id
  account_id   = "${local.client_slug}-${var.environment}"
  display_name = "${var.client_name} Data Pipeline (${var.environment})"
  roles = [
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/storage.objectAdmin",
    "roles/secretmanager.secretAccessor",
    "roles/run.invoker"
  ]
}

# Service Account for CI/CD
module "cicd_service_account" {
  source = "./modules/service-account"
  
  project_id   = local.project_id
  account_id   = "${local.client_slug}-cicd-${var.environment}"
  display_name = "${var.client_name} CI/CD (${var.environment})"
  roles = [
    "roles/artifactregistry.writer",
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/storage.objectViewer"
  ]
}

# Artifact Registry for containers
module "artifact_registry" {
  source = "./modules/artifact-registry"
  
  project_id    = local.project_id
  location      = var.region
  repository_id = "docker-repo"
  description   = "Container repository for ${var.client_name} ${var.environment}"
}

# Note: Cloud Run jobs are deployed via GitHub Actions / gcloud commands
# This keeps infrastructure (Terraform) separate from application deployment (CI/CD)

# Note: Cloud Schedulers are manually created to trigger Cloud Run jobs
# This simplifies the template and allows for flexible scheduling configuration