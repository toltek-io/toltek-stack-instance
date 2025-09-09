variable "folder_name" {
  description = "Display name for the folder"
  type        = string
}

variable "parent_id" {
  description = "Parent organization or folder ID (format: organizations/123 or folders/456)"
  type        = string
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