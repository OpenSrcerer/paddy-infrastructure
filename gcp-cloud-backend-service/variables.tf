variable "name" {}

variable "static_ip" {}

variable "instance_group" {}

variable "max_connections_per_instance" {}

variable "health_check" {}

variable proxy_connection_timeout_seconds {}

variable "target_ports" {
    type        = map(number)
}

variable "ssl_certificates" {
    type = list(string)    
}