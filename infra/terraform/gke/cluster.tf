resource "google_container_cluster" "gke" {
  name     = "gke-${lower(var.project_name)}-${var.environment}"
  description = "GKE cluster for the ${var.project_name} ${var.environment} project"

  location = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  enable_l4_ilb_subsetting = true

  network            = google_compute_network.network.id
  subnetwork         = google_compute_subnetwork.subnet.id

  ip_allocation_policy {
    stack_type                    = var.stack_type
    services_secondary_range_name = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
    cluster_secondary_range_name  = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
  }
  datapath_provider = var.stack_type == "IPV4_IPV6" ? "ADVANCED_DATAPATH" : "LEGACY_DATAPATH"

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = var.delete_protection

  # addons_config {
  #   http_load_balancing {
  #     disabled = false
  #   }
  #   horizontal_pod_autoscaling {
  #     disabled = false
  #   }
  # }

  # workload_identity_config {
  #   workload_pool = "${var.project_id}.svc.id.goog"
  # }
}

resource "google_container_node_pool" "default_pool" {
  name     = "${lower(var.project_name)}-${var.environment}-pool"
  location = var.region
  cluster  = google_container_cluster.gke.name

  initial_node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }

  node_config {
    machine_type = "e2-small"
    disk_size_gb = 20
    disk_type    = "pd-balanced"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    labels = {
      purpose = "general"
    }
    tags = ["gke-node"]
  }
}