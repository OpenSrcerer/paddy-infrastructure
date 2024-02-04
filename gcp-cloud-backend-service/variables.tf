variable "target_ports" {
  type = map(number)
}

variable "static_ip" {}

variable "service_protocol" {}

variable "proxy" {}

variable "health_check" {}

variable "group_manager" {}