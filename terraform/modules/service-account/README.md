# Service Account Module

This module creates a GCP service account and assigns IAM roles to it.

## Inputs
- `account_id`: The ID of the service account.
- `display_name`: The display name of the service account.
- `project_id`: The GCP project ID.
- `roles`: List of IAM roles to assign to the service account.

## Outputs
- `email`: The email address of the created service account.

## Example Usage

```
module "service_account" {
  source      = "../modules/service-account"
  account_id  = "cloudrun-dev"
  display_name = "Cloud Run Dev Service Account"
  project_id  = var.project_id
  roles       = ["roles/run.admin", "roles/iam.serviceAccountUser"]
}
``` 