variable "name" {}

variable "region" {}

variable "zone" {}

variable "instance_template" {}

variable "target_ports" {
  description = "Target ports to open in the managed group, each is health checked"
  type        = map(number)
}

variable "replicas" {
  type = number
}

variable "proxy_connection_timeout_seconds" {
  type    = number
  default = 600
}

variable "max_connections_per_instance" {
  description = "For the autoscaler"
  type        = number
  default     = 1000
}