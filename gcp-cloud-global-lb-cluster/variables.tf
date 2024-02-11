variable "name" {}

variable "region" {}

variable "zone" {}

variable "static_external_ip" {}

variable "static_internal_ip" {}

variable "instance_template" {}

variable "health_check_port" {}

variable "ssl_certificates" {
  type = list(string)
}

variable "tcp_target_ports" {
  description = "TCP target ports to open in the managed group"
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