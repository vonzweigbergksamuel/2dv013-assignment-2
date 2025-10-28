terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket = "bucket-${lower(var.project_name)}"
    prefix = "terraform/prod"
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
  environment  = "prod"
  region       = var.region

  ipv6_access_type = var.ipv6_access_type
  stack_type = var.stack_type
  delete_protection = var.delete_protection

  subnet_cidr = "10.0.0.0/16"
  services_range_cidr = "192.168.0.0/24"
  pod_ranges_cidr = "192.168.1.0/24"
}

module "deploy" {
  source = "../modules/deploy"

  project_id   = var.project_id
  region       = var.region
  cluster_name = module.gke.cluster_name
  namespace    = "prod"
  
  app_image    = "europe-west4-docker.pkg.dev/dv013-476513/docker-repo/just-task-it:latest"
  app_replicas = 3
}
