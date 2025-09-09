variable "account_id" {
  description = "The ID of the service account."
  type        = string
}

variable "display_name" {
  description = "The display name of the service account."
  type        = string
}

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "roles" {
  description = "List of IAM roles to assign to the service account."
  type        = list(string)
} 