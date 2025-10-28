resource "kubernetes_persistent_volume_claim" "influxdb" {
  metadata {
    name      = "influxdb-pvc"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class
    resources {
      requests = {
        storage = var.pvc_size
      }
    }
  }
}

resource "kubernetes_deployment_v1" "influxdb" {
  metadata {
    name      = "influxdb"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "influxdb"
      }
    }

    template {
      metadata {
        labels = {
          app = "influxdb"
        }
      }

      spec {
        container {
          name  = "influxdb"
          image = var.influxdb_image

          port {
            container_port = 8086
            name           = "influx"
          }

          env {
            name  = "DOCKER_INFLUXDB_INIT_MODE"
            value = "setup"
          }

          env {
            name  = "DOCKER_INFLUXDB_INIT_USERNAME"
            value = "admin"
          }

          env {
            name  = "DOCKER_INFLUXDB_INIT_PASSWORD"
            value = "admin123"
          }

          env {
            name  = "DOCKER_INFLUXDB_INIT_ORG"
            value = "jti-org"
          }

          env {
            name  = "DOCKER_INFLUXDB_INIT_BUCKET"
            value = "jti-bucket"
          }

          env {
            name  = "DOCKER_INFLUXDB_INIT_ADMIN_TOKEN"
            value = "my-super-secret-token"
          }

          volume_mount {
            name       = "influxdb-storage"
            mount_path = "/var/lib/influxdb"
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
        }

        volume {
          name = "influxdb-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.influxdb.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "influxdb" {
  metadata {
    name      = "influxdb"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = {
      app = "influxdb"
    }

    port {
      port        = 8086
      target_port = 8086
      name        = "influx"
    }
  }
}
