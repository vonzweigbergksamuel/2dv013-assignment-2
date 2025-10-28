variable "project_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "ipv6_access_type" {
  description = "Access type of the ipv6"
  type = string
  default = "EXTERNAL" # Change to "INTERNAL" if creating an internal loadbalancer
}

variable "stack_type" {
  description = "Stack type of the ipv4/ipv6"
  type = string
  default = "IPV4_IPV6"
}

variable "delete_protection" {
  description = "Delete protection of the cluster"
  type = bool
  default = true # Change to false if you want to allow the cluster to be deleted
}