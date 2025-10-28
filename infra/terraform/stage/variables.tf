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
  default = "INTERNAL" # Change to "EXTERNAL" if creating an external loadbalancer
}

variable "stack_type" {
  description = "Stack type of the ipv4/ipv6"
  type = string
  default = "IPV4_IPV6"
}

variable "delete_protection" {
  description = "Delete protection of the cluster"
  type = bool
  default = false # Change to true if you want to protect the cluster from deletion
}