resource "google_project_service" "apis" {
  for_each = toset(var.apis)
  
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_storage_bucket" "tfstate" {
  name                        = "bucket-${lower(var.project_name)}"
  location                    = "EU"
  uniform_bucket_level_access = true
  versioning { 
    enabled = true 
  }

  depends_on = [google_project_service.apis]
}

resource "google_storage_bucket_iam_member" "tfstate_object_admin" {
  bucket = google_storage_bucket.tfstate.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.devops_service_account_email}"
}
