variable "name" {}

variable "network_name" {}

// ---- BACKEND-ENV-VARS ----
variable "backend_mqtt_host" {
  default = "<unset>"
}

variable "backend_mqtt_port" {
  default = "<unset>"
}

variable "backend_mqtt_subscriptions" {
  default = "<unset>"
}

variable "backend_auth_service_url" {
  default = "<unset>"
}