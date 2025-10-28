resource "kubernetes_persistent_volume_claim" "mongodb" {
  metadata {
    name      = "mongodb-pvc"
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

resource "kubernetes_stateful_set_v1" "mongodb" {
  metadata {
    name      = "mongodb"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    service_name = kubernetes_service_v1.mongodb.metadata[0].name
    replicas     = 1

    selector {
      match_labels = {
        app = "mongodb"
      }
    }

    template {
      metadata {
        labels = {
          app = "mongodb"
        }
      }

      spec {
        container {
          name  = "mongodb"
          image = var.mongodb_image

          port {
            container_port = 27017
            name           = "mongodb"
          }

          volume_mount {
            name       = "mongodb-storage"
            mount_path = "/data/db"
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
          name = "mongodb-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mongodb.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "mongodb" {
  metadata {
    name      = "mongodb"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    cluster_ip = "None"
    selector = {
      app = "mongodb"
    }

    port {
      port        = 27017
      target_port = 27017
      name        = "mongodb"
    }
  }
}
