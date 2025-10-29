output "cluster_name" {
  value = google_container_cluster.gke.name
}

output "cluster_endpoint" {
  value = google_container_cluster.gke.endpoint
}

output "region" {
  value = var.region
}

output "network_name" {
  value = google_compute_network.network.name
}
