locals {
  client_slug = "toltek"
  client_name = "Toltek"
} 

remote_state {
  backend = "gcs"
  config = {
    bucket  = "-terraform-state"
    prefix  = "${local.client_slug}/folder/${path_relative_to_include()}"
    project = "-dev"
    location = ""
  }
}

terraform {
  source = "../../"
}

inputs = {
  project_id         = "-dev"
  region             = ""
  environment        = "dev"
  client_name        = local.client_name
  organization_id    = "organizations/YOUR_ORG_ID"
  create_folder      = true
  create_project     = false
  billing_account_id = "YOUR_BILLING_ACCOUNT_ID"
  
  folder_admins = [
    # "group:${local.client_slug}-admins@yourdomain.com",
    # "user:admin@yourdomain.com"
  ]
  
  billing_users = [
    # "group:${local.client_slug}-billing@yourdomain.com"
  ]
}