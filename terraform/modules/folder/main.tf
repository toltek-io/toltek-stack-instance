resource "google_folder" "client_folder" {
  display_name = var.folder_name
  parent       = var.parent_id
}

resource "google_folder_iam_binding" "folder_admin" {
  count  = length(var.folder_admins) > 0 ? 1 : 0
  folder = google_folder.client_folder.name
  role   = "roles/resourcemanager.folderAdmin"
  members = var.folder_admins
}

resource "google_folder_iam_binding" "billing_user" {
  count  = length(var.billing_users) > 0 ? 1 : 0
  folder = google_folder.client_folder.name
  role   = "roles/billing.user"
  members = var.billing_users
}