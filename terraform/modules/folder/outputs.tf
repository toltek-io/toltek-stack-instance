output "folder_id" {
  description = "The folder ID"
  value       = google_folder.client_folder.name
}

output "folder_display_name" {
  description = "The folder display name"
  value       = google_folder.client_folder.display_name
}