variable "name" {}

variable "allowed_internal_communication_ports" {
  type = list(string)
}

variable "allowed_internal_communication_ports_block" {
  type = list(string)
}

variable "allowed_ports_tcp_anyip" {
  type = list(string)
}