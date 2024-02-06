variable "name" {}

variable "domain_name" {}

variable "dns_records" {
    type = map(string)
}