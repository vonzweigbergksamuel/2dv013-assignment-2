resource "google_secret_manager_secret" "github_oauth" {
  secret_id = "github-connection-oauth"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "github_oauth_version" {
  secret      = google_secret_manager_secret.github_oauth.id
  secret_data = file("${path.module}/github-token.txt")
}

data "google_project" "default" {
  project_id = var.project_id
}

resource "google_secret_manager_secret_iam_member" "cloud_build_github_oauth_member" {
  secret_id = google_secret_manager_secret.github_oauth.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:service-${data.google_project.default.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

resource "google_cloudbuildv2_connection" "github" {
  count    = var.create_connection ? 1 : 0
  location = var.region
  name     = "github-connection"
  project  = var.project_id

  github_config {
    app_installation_id = var.app_installation_id
    authorizer_credential {
      oauth_token_secret_version = "${google_secret_manager_secret.github_oauth.id}/versions/latest"
    }
  }

  depends_on = [google_secret_manager_secret_version.github_oauth_version]
}

resource "google_cloudbuildv2_repository" "github" {
  count             = var.create_connection ? 1 : 0
  location          = var.region
  name              = "github-repo"
  parent_connection = google_cloudbuildv2_connection.github[0].name
  remote_uri        = "https://github.com/${var.github_repo}.git"
}
