provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

module "paddy_nw" {
  source                  = "./gcp-cloud-network"
  name                    = "paddy-network"
  allowed_ports_tcp_anyip = ["22", "1883"]
}

module "paddy_vm" {
  source       = "./gcp-cloud-vm"
  name         = "paddy-machine"
  network_name = module.paddy_nw.network_name

  backend_mqtt_host = var.backend_mqtt_host
  backend_mqtt_port = var.backend_mqtt_port
  backend_mqtt_subscriptions = var.backend_mqtt_subscriptions

  amount       = 1
}