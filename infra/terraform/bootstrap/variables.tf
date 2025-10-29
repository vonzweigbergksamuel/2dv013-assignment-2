variable "project_id" {
  description = "ID of the project on google cloud"
  type        = string
}

variable "region" {
  description = "Region of the project"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "apis" {
  description = "APIs to enable"
  type        = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com"
  ]
}

variable "devops_service_account_email" {
  description = "Email of the existing DevOps service account"
  type        = string
}