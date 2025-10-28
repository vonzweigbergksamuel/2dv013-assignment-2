resource "kubernetes_deployment_v1" "telegraf" {
  metadata {
    name      = "telegraf"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "telegraf"
      }
    }

    template {
      metadata {
        labels = {
          app = "telegraf"
        }
      }

      spec {
        container {
          name  = "telegraf"
          image = var.telegraf_image

          env {
            name  = "INFLUX_URL"
            value = "http://influxdb:8086"
          }

          env {
            name  = "INFLUX_ORG"
            value = "jti-org"
          }

          env {
            name  = "INFLUX_BUCKET"
            value = "jti-bucket"
          }

          env {
            name  = "INFLUX_TOKEN"
            value = "my-super-secret-token"
          }

          env {
            name  = "RABBITMQ_USER"
            value = "admin"
          }

          env {
            name  = "RABBITMQ_PASS"
            value = "admin"
          }

          env {
            name  = "RABBITMQ_QUEUE"
            value = "task-events"
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_deployment_v1.influxdb,
    kubernetes_deployment_v1.rabbitmq
  ]
}
