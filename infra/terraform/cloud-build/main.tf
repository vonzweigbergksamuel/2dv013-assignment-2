resource "google_secret_manager_secret" "github_token_secret" {
  secret_id = "github-token-secret"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "github_token_secret_version" {
  secret      = google_secret_manager_secret.github_token_secret.id
  secret_data = file("${path.module}/github-token.txt")
}

data "google_project" "default" {
  project_id = var.project_id
}

data "google_iam_policy" "p4sa_secret_accessor" {
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = ["serviceAccount:service-${data.google_project.default.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
  }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  secret_id   = google_secret_manager_secret.github_token_secret.secret_id
  policy_data = data.google_iam_policy.p4sa_secret_accessor.policy_data
}

resource "google_cloudbuildv2_connection" "github" {
  location = var.region
  name     = "github-connection"

  github_config {
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github_token_secret_version.id
    }
  }
}

resource "google_cloudbuildv2_repository" "github" {
  location          = var.region
  name              = "github-repo"
  parent_connection = google_cloudbuildv2_connection.github.name
  remote_uri        = "https://github.com/${var.github_repo}.git"
}
