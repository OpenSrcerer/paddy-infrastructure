locals {
  project_id_digits = regex(".*-(\\d+)", var.project)[0]
}

resource "google_certificate_manager_trust_config" "default" {
  provider = google-beta
  name     = "${var.name}-mtls-trust-config"
  location = "global"
  project  = var.project

  trust_stores {
    trust_anchors {
      pem_certificate = var.root_ca
    }
    intermediate_cas {
      pem_certificate = var.server_ca
    }
  }
}

resource "google_network_security_server_tls_policy" "default" {
  provider   = google-beta
  name       = "${var.name}-mtls-policy"
  location   = "global"
  allow_open = "false" # Skips client cert checking if true
  project    = var.project

  mtls_policy {
    client_validation_mode         = "REJECT_INVALID"
    client_validation_trust_config = "projects/${local.project_id_digits}/locations/global/trustConfigs/${google_certificate_manager_trust_config.default.name}"
  }
}