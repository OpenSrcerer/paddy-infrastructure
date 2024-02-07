provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.14.0"
    }
  }
}

# ----- Network Configuration -----
module "paddy_nw" {
  source = "./gcp-cloud-network"

  name                                       = "paddy-network"
  allowed_internal_communication_ports_block = ["10.172.0.0/20"]
  allowed_ports_tcp_anyip                    = ["22", "443", "8883"]
}

module "paddy_internal_dns" {
  source = "./gcp-cloud-internal-dns"

  name        = "paddy"
  domain_name = "paddy.internal"
  network     = module.paddy_nw.self_link
  dns_records = { "10.172.0.2" = "auth" }
}
# ---------------------------------

module "paddy_backend_instance_template" {
  source = "./gcp-cloud-vm-template"

  name         = "paddy-machine"
  network_name = module.paddy_nw.network_name

  backend_mqtt_host          = var.backend_mqtt_host
  backend_mqtt_port          = var.backend_mqtt_port
  backend_mqtt_subscriptions = var.backend_mqtt_subscriptions
  backend_auth_service_url   = var.backend_auth_service_url
}

module "gcp_cloud_global_lb_cluster" {
  source = "./gcp-cloud-global-lb-cluster"

  name              = "broker-node"
  project           = var.project
  zone              = var.zone
  region            = var.region
  instance_template = module.paddy_backend_instance_template.self_link

  tcp_target_ports       = { "mqtts" = 8883 }
  tls_target_ports       = { "https" = 443 }
  health_check_port      = 8883
  ssl_certificate_domain = "mqtt.danielstefani.online"

  private_key         = var.private_key
  private_certificate = var.private_certificate

  replicas = 1
}

module "paddy_auth_single_instance" {
  source = "./gcp-cloud-vm"

  name         = "auth"
  internal_ip  = "10.172.0.2"
  zone         = var.zone
  network_name = module.paddy_nw.network_name

  backend_mqtt_authentication_key = var.backend_mqtt_authentication_key
}