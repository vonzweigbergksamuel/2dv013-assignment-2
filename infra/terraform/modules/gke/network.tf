resource "google_compute_network" "network" {
  name                    = "${var.project_name}-${var.environment}-network"
  description             = "Network for the ${var.project_name} ${var.environment} cluster"

  auto_create_subnetworks = false
  enable_ula_internal_ipv6 = true
}

resource "google_compute_subnetwork" "subnet" {
  name = "${var.project_name}-${var.environment}-subnet"

  ip_cidr_range = var.subnet_cidr
  region        = var.region

  stack_type       = var.stack_type
  ipv6_access_type = var.ipv6_access_type

  network = google_compute_network.network.id
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = var.services_range_cidr
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = var.pod_ranges_cidr
  }
}