variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "app_image" {
  type = string
}

variable "app_name" {
  type    = string
  default = "just-task-it"
}

variable "app_replicas" {
  type    = number
  default = 2
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "mongodb_image" {
  type    = string
  default = "mongo:8.0.0"
}

variable "redis_image" {
  type    = string
  default = "redis:latest"
}

variable "rabbitmq_image" {
  type    = string
  default = "rabbitmq:4-management"
}

variable "influxdb_image" {
  type    = string
  default = "influxdb:latest"
}

variable "telegraf_image" {
  type    = string
  default = "telegraf:latest"
}

variable "grafana_image" {
  type    = string
  default = "grafana/grafana"
}

variable "storage_class" {
  type    = string
  default = "standard"
}

variable "pvc_size" {
  type    = string
  default = "10Gi"
}
