variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = ""
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = ""
}

variable "client_name" {
  description = "Client name"
  type        = string
  default     = "Toltek"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = ""
}

variable "organization_id" {
  description = "GCP Organization ID (format: organizations/123456789)"
  type        = string
  default     = null
}

variable "folder_id" {
  description = "Parent folder ID for projects"
  type        = string
  default     = null
}

variable "create_project" {
  description = "Whether to create the project (false if using existing)"
  type        = bool
  default     = false
}

variable "create_folder" {
  description = "Whether to create the client folder"
  type        = bool
  default     = false
}

variable "billing_account_id" {
  description = "Billing account ID"
  type        = string
  default     = null
}

variable "folder_admins" {
  description = "List of users/groups with folder admin access"
  type        = list(string)
  default     = []
}

variable "billing_users" {
  description = "List of users/groups with billing access"
  type        = list(string)
  default     = []
}

variable "required_apis" {
  description = "Required GCP APIs to enable"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudscheduler.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com"
  ]
}

# Note: image_tag variable removed as Cloud Run is deployed via GitHub Actions

