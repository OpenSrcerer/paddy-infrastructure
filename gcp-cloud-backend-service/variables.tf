variable "name" {}

variable "global_static_ip" {}

variable "internal_static_ip" {}

variable "instance_group" {}

variable "max_connections_per_instance" {}

variable "health_check" {}

variable "proxy_connection_timeout_seconds" {}

variable "security_policy" {
  default = null
}

variable "target_ports" {
  type = map(number)
}

variable "ssl_certificates" {
  type = list(string)
}