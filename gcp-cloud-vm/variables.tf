variable "name" {}

variable "network_name" {}

variable "zone" {}

// ---- BACKEND-ENV-VARS ----
variable "backend_mqtt_authentication_key" {
  default = "<unset>"
}