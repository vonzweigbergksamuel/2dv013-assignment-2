output "tfstate_bucket" {
  description = "GCS bucket for Terraform state"
  value       = google_storage_bucket.tfstate.name
}

output "devops_service_account_email" {
  value = var.devops_service_account_email
}