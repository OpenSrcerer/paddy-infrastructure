variable "name" {}

variable "network_name" {}

variable "amount" {
  type = number
}

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