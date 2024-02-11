variable "name" {}

variable "ssl_certificate_domain" {
  description = "For the managed certificate"
}

variable "private_key" {
  description = "For the self managed certificate"
}

variable "private_certificate" {
  description = "For the self managed certificate"
}