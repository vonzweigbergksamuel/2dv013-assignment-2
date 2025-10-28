resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    DB_CONNECTION_STRING = "mongodb://mongodb:27017/just-task-it"
    RABBITMQ_URL         = "amqp://admin:admin@rabbitmq:5672"
    INFLUX_URL           = "http://influxdb:8086"
    BASE_URL             = "/"
    LOG_LEVEL            = "info"
  }
}

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "app-secrets"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    SESSION_SECRET = base64encode("your-secret-key-change-me-in-production")
  }
}
