# ----- Terraform Setup -----
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
# ---------------------------------

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
  dns_records = {
    "10.172.0.2" = "auth"
    "10.172.0.3" = "postgres-master"
    "10.172.0.4" = "backend"
  }
}

module "paddy_certs" {
  source = "./gcp-cloud-certs"
  name = "paddy"

  ssl_certificate_domain = "mqtt.danielstefani.online"
  private_key         = var.private_key
  private_certificate = var.private_certificate
}

resource "google_compute_global_address" "static-global-ip" {
  name = "paddy-external-ip-address"
}
# ---------------------------------


# ----- Single Instances -----
module "paddy_auth_single_instance" {
  source = "./gcp-cloud-vm"

  name         = "auth"
  internal_ip  = "10.172.0.2"
  zone         = var.zone
  instance_type = "e2-micro"
  network_name = module.paddy_nw.network_name

  startup_script = file("${path.module}/vm-startup-scripts/auth-startup-script.sh")

  backend_mqtt_authentication_key = var.backend_mqtt_authentication_key
}

module "postgres_master_single_instance" {
  source = "./gcp-cloud-vm"

  name         = "postgres-master"
  internal_ip  = "10.172.0.3"
  zone         = var.zone
  instance_type = "e2-small"
  network_name = module.paddy_nw.network_name

  startup_script = file("${path.module}/vm-startup-scripts/db-master-startup-script.sh")
}
# ------------------------------


# ----- Cluster Templates -----
module "paddy_broker_instance_template" {
  source = "./gcp-cloud-vm-template"

  name         = "paddy-broker"
  network_name = module.paddy_nw.network_name
  instance_type = "e2-small"

  startup_script = file("${path.module}/vm-startup-scripts/broker-startup-script.sh")
}

module "paddy_backend_instance_template" {
  source = "./gcp-cloud-vm-template"

  name         = "paddy-backend"
  network_name = module.paddy_nw.network_name
  instance_type = "e2-micro"

  backend_mqtt_host          = var.backend_mqtt_host
  backend_mqtt_port          = var.backend_mqtt_port
  backend_mqtt_subscriptions = var.backend_mqtt_subscriptions
  backend_auth_service_url   = var.backend_auth_service_url

  startup_script = file("${path.module}/vm-startup-scripts/backend-startup-script.sh")
}
# ------------------------------


# ----- Clusters -----
module "broker_global_lb_cluster" {
  source = "./gcp-cloud-global-lb-cluster"

  name              = "broker-cluster"
  zone              = var.zone
  region            = var.region
  static_external_ip = google_compute_global_address.static-global-ip.self_link
  instance_template = module.paddy_broker_instance_template.self_link

  tcp_target_ports       = { "mqtts" = 8883 }
  health_check_port      = 8883

  ssl_certificates = [module.paddy_certs.self_ssl_cert]

  replicas = 2
}

module "backend_global_lb_cluster" {
  source = "./gcp-cloud-global-lb-cluster"

  name              = "backend-cluster"
  zone              = var.zone
  region            = var.region
  static_external_ip = google_compute_global_address.static-global-ip.self_link
  instance_template = module.paddy_backend_instance_template.self_link

  tcp_target_ports       = { "https" = 443 }
  health_check_port      = 443

  ssl_certificates = [module.paddy_certs.managed_ssl_cert]

  replicas = 1
}
# --------------------