variable "project" {}

variable "region" {
  default = "europe-west6"
}

variable "zone" {
  default = "europe-west6-a"
}

// ---- BACKEND-ENV-VARS ----
variable "backend_mqtt_host" {
  description = "Broker for the backend MQTT connection"
  type        = string
}

variable "backend_mqtt_port" {
  description = "Broker port for the backend MQTT connection"
  type        = string
}

variable "backend_mqtt_subscriptions" {
  description = "Where the backend should listen to for machine messages"
  type        = string
}