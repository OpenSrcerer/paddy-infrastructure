variable "name" {}

variable "network_name" {}

variable "internal_ip" {}

variable "zone" {}

variable "instance_type" {}

variable "disk_size" {
  type    = number
  default = null
}

variable "image" {
  type    = string
  default = "cos-cloud/cos-stable"
}

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

variable "backend_mqtt_authentication_key" {
  default = "<unset>"
}

variable "backend_mqtt_scheduler_events" {
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