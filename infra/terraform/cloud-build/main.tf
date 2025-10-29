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

resource "google_cloudbuildv2_repository" "github" {
  location          = var.region
  name              = "github-repo"
  parent_connection = "projects/${var.project_id}/locations/${var.region}/connections/github"
  remote_uri        = "https://github.com/${var.github_repo}.git"
}

resource "google_cloudbuild_trigger" "docker_build" {
  location   = var.region
  project    = var.project_id
  name       = "docker-build-trigger"
  filename   = "cloudbuild.yaml"

  trigger_template {
    branch_name = "main"
    repo_name   = google_cloudbuildv2_repository.github.name
  }

  depends_on = [google_cloudbuildv2_repository.github]
}

output "cloud_build_trigger_id" {
  value = google_cloudbuild_trigger.docker_build.id
}
