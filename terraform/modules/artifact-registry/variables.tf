variable "location" {
  description = "The location for the Artifact Registry repository."
  type        = string
}

variable "repository_id" {
  description = "The name of the Artifact Registry repository."
  type        = string
}

variable "description" {
  description = "A description for the repository."
  type        = string
  default     = ""
}

variable "project_id" {
  description = "The GCP project ID."
  type        = string
} 