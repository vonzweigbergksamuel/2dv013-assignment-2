terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket = "bucket-${lower(var.project_name)}"
    prefix = "terraform/stage"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "gke" {
  source = "../modules/gke"

  project_id   = var.project_id
  project_name = var.project_name
  environment  = "stage"
  region       = var.region

  ipv6_access_type = "INTERNAL"
  stack_type = "IPV4_IPV6"
  delete_protection = false

  subnet_cidr = "10.0.0.0/16"
  services_range_cidr = "192.168.0.0/24"
  pod_ranges_cidr = "192.168.1.0/24"
}
