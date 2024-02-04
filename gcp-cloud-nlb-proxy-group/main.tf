resource "google_compute_global_address" "static" {
  name = "${var.name}-ip-address"
}

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

# ----- BY PORT CONFIGURATION -----
resource "google_compute_target_ssl_proxy" "mqtts-proxy" {
  for_each = var.tcp_target_ports

  name            = "${var.name}-target-ssl-proxy-${each.key}"
  backend_service = google_compute_backend_service.tcp_backend_service[each.key].self_link
  ssl_certificates = [google_compute_ssl_certificate.default.self_link]
}

resource "google_compute_global_forwarding_rule" "tcp_forwarding_rule" {
  for_each = var.tcp_target_ports

  name = "${var.name}-lb-forwarding-rule-${each.key}"

  ip_protocol = "TCP"
  port_range  = each.value
  ip_address  = google_compute_global_address.static.self_link

  target = google_compute_target_ssl_proxy.mqtts-proxy[each.key].self_link
}

resource "google_compute_backend_service" "tcp_backend_service" {
  for_each = var.tcp_target_ports

  name          = "${var.name}-lb-backend-service-${each.key}"
  port_name     = each.key
  protocol      = "TCP"
  timeout_sec   = var.proxy_connection_timeout_seconds
  health_checks = [google_compute_health_check.tcp_health_check.self_link]

  backend {
    group                        = google_compute_instance_group_manager.default.instance_group
    balancing_mode               = "CONNECTION"
    max_connections_per_instance = var.max_connections_per_instance
  }
}

module "managed_cert_backend_service" {
  source = "../gcp-cloud-backend-service"

  name = "${var.name}-managed-cert"
  static_ip = google_compute_global_address.static.self_link
  instance_group = google_compute_instance_group_manager.default.instance_group
  max_connections_per_instance = var.max_connections_per_instance
  health_check = google_compute_health_check.tcp_health_check.self_link
  proxy_connection_timeout_seconds = var.proxy_connection_timeout_seconds
  target_ports = var.tls_target_ports
  ssl_certificates = [google_compute_managed_ssl_certificate.default.self_link]
}

# ----- SINGLE CONFIGURATION -----

resource "google_compute_health_check" "tcp_health_check" {
  name                = "${var.name}-tcp-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  tcp_health_check {
    port = var.health_check_port
  }
}

resource "google_compute_instance_group_manager" "default" {
  name = "${var.name}-instance-group"

  base_instance_name = var.name
  zone               = var.zone

  auto_healing_policies {
    health_check      = google_compute_health_check.tcp_health_check.id
    initial_delay_sec = 300
  }

  update_policy {
    type                    = "OPPORTUNISTIC"
    minimal_action          = "REPLACE"
    replacement_method      = "SUBSTITUTE"
    max_unavailable_percent = 50
  }

  version {
    instance_template = var.instance_template
  }

  dynamic "named_port" {
    for_each = merge(var.tcp_target_ports, var.tls_target_ports)

    content {
      name = named_port.key
      port = named_port.value
    }
  }

  target_size = var.replicas
}