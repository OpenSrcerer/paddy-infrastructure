# Managed certificate for HTTPS calls (where client can't provide their own)
resource "google_compute_managed_ssl_certificate" "default" {
    name = "${var.name}-ssl-cert"

    managed {
        domains = [var.ssl_certificate_domain]
    }
}

# Self signed cert for MQTT where the client needs to provide their own certificate
resource "google_compute_ssl_certificate" "default" {
    name = "${var.name}-self-ssl-cert"

    private_key = var.private_key
    certificate = var.private_certificate

    lifecycle {
        create_before_destroy = true
    }
}