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
variable "backend_mqtt_authentication_key" {
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