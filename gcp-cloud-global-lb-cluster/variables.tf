variable "name" {}

variable "region" {}

variable "zone" {}

variable "instance_template" {}

variable "ssl_certificate_domain" {}

variable "project" {}

variable "tcp_target_ports" {
  description = "TCP target ports to open in the managed group"
  type        = map(number)
}

variable "tls_target_ports" {
  description = "HTTPS (TLS) target ports to open in the managed group"
  type        = map(number)
}

variable "health_check_port" {}

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

variable "private_key" {}

variable "private_certificate" {}