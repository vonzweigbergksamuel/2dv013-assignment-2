terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket = "bucket-2dv013"
    prefix = "terraform/cloud-build"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
