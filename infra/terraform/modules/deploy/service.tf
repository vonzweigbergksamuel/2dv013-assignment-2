resource "kubernetes_service_v1" "app" {
  metadata {
    name = "${var.app_name}-service"
    annotations = {
      "networking.gke.io/load-balancer-type" = var.load_balancer_type
    }
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.app.spec[0].selector[0].match_labels.app
    }

    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }

  depends_on = [kubernetes_deployment_v1.app]
}
