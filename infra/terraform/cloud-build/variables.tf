variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "github_repo" {
  type        = string
  description = "GitHub repository in format: owner/repo"
}

variable "create_connection" {
  type        = bool
  default     = false
  description = "Create connection only after manually adding secrets to Secret Manager"
}

variable "app_installation_id" {
  type        = number
  default     = null
  description = "GitHub Cloud Build App installation ID from GitHub settings"
}
