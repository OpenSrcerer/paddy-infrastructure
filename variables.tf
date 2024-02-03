variable "project" {}

variable "region" {
  default = "europe-west6"
}

variable "zone" {
  default = "europe-west6-a"
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