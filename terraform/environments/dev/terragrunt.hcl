# First apply folder if needed
dependency "folder" {
  config_path = "../folder"
  mock_outputs = {
    folder_id = "folders/123456789"
  }
  skip_outputs = true
}

locals {
  project_id = "-dev"
  region     = ""
  environment = "dev"
  client_slug = "toltek"
} 

remote_state {
  backend = "gcs"
  config = {
    bucket  = "${local.project_id}-terraform-state"
    prefix  = "${local.client_slug}/dev/${path_relative_to_include()}"
    project = local.project_id
    location = ""
  }
}

terraform {
  source = "../../"
}

inputs = {
  project_id         = local.project_id
  region             = local.region
  environment        = local.environment
  client_name        = "Toltek"
  organization_id    = "organizations/YOUR_ORG_ID"
  folder_id          = "folders/YOUR_FOLDER_ID"
  create_project     = false
  create_folder      = false
  billing_account_id = "YOUR_BILLING_ACCOUNT_ID"
  image_tag          = "latest"  # Default value, can be overridden via CLI
}