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

resource "google_cloudbuild_trigger" "docker_build" {
  location = var.region
  name     = "docker-build-trigger"

  repository_event_config {
    repository = google_cloudbuildv2_repository.github.id
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"

  depends_on = [
    google_cloudbuildv2_repository.github
  ]
}

output "cloud_build_connection_id" {
  value = google_cloudbuildv2_connection.github.id
}

output "cloud_build_trigger_id" {
  value = google_cloudbuild_trigger.docker_build.id
}
