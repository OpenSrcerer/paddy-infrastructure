variable "name" {}

variable "network_name" {}

variable "instance_type" {}

variable "startup_script" {
  type = string
}

// ---- BACKEND-ENV-VARS ----
variable "backend_mqtt_host" {
  default = "<unset>"
}

variable "backend_mqtt_port" {
  default = "<unset>"
}

variable "backend_mqtt_device_read_topic" {
  default = "<unset>"
}

variable "backend_mqtt_subscriptions" {
  default = "<unset>"
}

variable "backend_auth_service_url" {
  default = "<unset>"
}

// ---- NEO4J CREDENTIALS ----
variable "backend_db_uri" {
  default = "<unset>"
}

variable "backend_db_user" {
  default = "<unset>"
}

variable "backend_db_password" {
  default = "<unset>"
}