variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "ipv6_access_type" {
  type = string
}

variable "stack_type" {
  type = string
}

variable "delete_protection" {
  type = bool
}

variable "subnet_cidr" {
  type = string
}

variable "services_range_cidr" {
  type = string
}

variable "pod_ranges_cidr" {
  type = string
}

variable "environment" {
  type = string
}