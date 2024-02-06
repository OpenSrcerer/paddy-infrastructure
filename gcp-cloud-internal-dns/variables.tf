variable "name" {}

variable "domain_name" {}

variable "network" {}

variable "dns_records" {
  type = map(string)
}