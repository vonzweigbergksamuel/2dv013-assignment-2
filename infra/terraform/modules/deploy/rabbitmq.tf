resource "kubernetes_deployment_v1" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "rabbitmq"
      }
    }

    template {
      metadata {
        labels = {
          app = "rabbitmq"
        }
      }

      spec {
        container {
          name  = "rabbitmq"
          image = var.rabbitmq_image

          port {
            container_port = 5672
            name           = "amqp"
          }

          port {
            container_port = 15672
            name           = "management"
          }

          env {
            name  = "RABBITMQ_DEFAULT_USER"
            value = "admin"
          }

          env {
            name  = "RABBITMQ_DEFAULT_PASS"
            value = "admin"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          readiness_probe {
            exec {
              command = ["rabbitmq-diagnostics", "ping"]
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = {
      app = "rabbitmq"
    }

    port {
      port        = 5672
      target_port = 5672
      name        = "amqp"
    }

    port {
      port        = 15672
      target_port = 15672
      name        = "management"
    }
  }
}
