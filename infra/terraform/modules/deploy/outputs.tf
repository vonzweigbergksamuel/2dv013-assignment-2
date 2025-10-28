output "app_service_endpoint" {
  value       = try(kubernetes_service_v1.app.status[0].load_balancer[0].ingress[0].ip, "pending")
  description = "Application LoadBalancer IP"
}

output "grafana_service_endpoint" {
  value       = try(kubernetes_service_v1.grafana.status[0].load_balancer[0].ingress[0].ip, "pending")
  description = "Grafana LoadBalancer IP"
}

output "mongodb_service" {
  value       = kubernetes_service_v1.mongodb.metadata[0].name
  description = "MongoDB service name"
}

output "redis_service" {
  value       = kubernetes_service_v1.redis.metadata[0].name
  description = "Redis service name"
}

output "rabbitmq_service" {
  value       = kubernetes_service_v1.rabbitmq.metadata[0].name
  description = "RabbitMQ service name"
}

output "influxdb_service" {
  value       = kubernetes_service_v1.influxdb.metadata[0].name
  description = "InfluxDB service name"
}

output "namespace" {
  value       = kubernetes_namespace.app.metadata[0].name
  description = "Kubernetes namespace"
}
