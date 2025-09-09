output "repository_url" {
  description = "The URL of the Artifact Registry repository."
  value       = "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.name}"
} 