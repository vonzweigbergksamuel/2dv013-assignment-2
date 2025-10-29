resource "google_secret_manager_secret" "github_token" {
  secret_id = "github-token"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "github_token_version" {
  secret      = google_secret_manager_secret.github_token.id
  secret_data = file("${path.module}/github-token.txt")
}

data "google_project" "default" {
  project_id = var.project_id
}

data "google_iam_policy" "cloud_build_secret_accessor" {
  binding {
    role    = "roles/secretmanager.secretAccessor"
    members = ["serviceAccount:service-${data.google_project.default.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
  }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  secret_id   = google_secret_manager_secret.github_token.secret_id
  policy_data = data.google_iam_policy.cloud_build_secret_accessor.policy_data
}

resource "google_cloudbuildv2_connection" "github" {
  location = var.region
  name     = "github-connection"

  github_config {
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github_token_version.id
    }
  }
}

resource "google_cloudbuildv2_repository" "github" {
  location            = var.region
  name                = "github-repo"
  parent_connection   = google_cloudbuildv2_connection.github.name
  remote_uri          = "https://github.com/${var.github_repo}.git"
}

resource "google_service_account" "cloud_build" {
  account_id   = "cloud-build-sa"
  display_name = "Cloud Build Service Account"
}

resource "google_project_iam_member" "cloud_build_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_project_iam_member" "cloud_build_artifact_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_cloudbuild_trigger" "docker_build" {
  location = var.region
  name     = "docker-build-trigger"

  repository_event_config {
    repository = google_cloudbuildv2_repository.github.id
    push {
      branch = "^main$"
    }
  }

  filename        = "cloudbuild.yaml"
  service_account = google_service_account.cloud_build.id

  depends_on = [
    google_cloudbuildv2_repository.github,
    google_project_iam_member.cloud_build_storage_admin,
    google_project_iam_member.cloud_build_artifact_registry
  ]
}

output "cloud_build_trigger_id" {
  value = google_cloudbuild_trigger.docker_build.id
}
