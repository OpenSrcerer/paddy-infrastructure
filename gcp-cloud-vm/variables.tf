variable "name" {}

variable "network_name" {}

variable "internal_ip" {}

variable "zone" {}

variable "instance_type" {}

variable "startup_script" {
  type = string
}

// ---- BACKEND-ENV-VARS ----
variable "backend_mqtt_authentication_key" {
  default = "<unset>"
}