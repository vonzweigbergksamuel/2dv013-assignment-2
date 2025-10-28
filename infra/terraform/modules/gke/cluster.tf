resource "google_container_cluster" "gke" {
  name     = "${var.project_name}-${var.environment}-gke"
  description = "GKE cluster for the ${var.project_name} ${var.environment} project"

  location = var.region
  enable_autopilot = true
  enable_l4_ilb_subsetting = true

  network            = google_compute_network.network.id
  subnetwork         = google_compute_subnetwork.subnet.id

  ip_allocation_policy {
    stack_type                    = var.stack_type
    services_secondary_range_name = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
    cluster_secondary_range_name  = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
  }

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = var.delete_protection

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

# resource "google_container_node_pool" "primary" {
#   name           = "${var.project_name}-${var.environment}-node-pool"
#   location       = var.region
#   cluster        = google_container_cluster.gke.name
#   node_count     = var.node_count
#   node_locations = [var.region]

#   node_config {
#     machine_type = var.machine_type
#     disk_size_gb = var.disk_size_gb

#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]

#     workload_metadata_config {
#       mode = "GKE_METADATA"
#     }
#   }

#   autoscaling {
#     min_node_count = var.min_node_count
#     max_node_count = var.max_node_count
#   }
# }

# resource "google_service_account" "gke_sa" {
#   account_id   = "${var.project_name}-${var.environment}-gke"
#   display_name = "GKE Service Account for ${var.environment}"
# }

# resource "google_project_iam_member" "gke_sa_log_writer" {
#   project = var.project_id
#   role    = "roles/logging.logWriter"
#   member  = "serviceAccount:${google_service_account.gke_sa.email}"
# }

# resource "google_project_iam_member" "gke_sa_metric_writer" {
#   project = var.project_id
#   role    = "roles/monitoring.metricWriter"
#   member  = "serviceAccount:${google_service_account.gke_sa.email}"
# }
