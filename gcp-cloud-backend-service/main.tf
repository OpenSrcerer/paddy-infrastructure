resource "google_compute_target_ssl_proxy" "default" {
  for_each = var.target_ports

  name             = "${var.name}-target-ssl-proxy-${each.key}"
  backend_service  = google_compute_backend_service.backend_service[each.key].self_link
  ssl_certificates = var.ssl_certificates
}

resource "google_compute_global_forwarding_rule" "tcp_forwarding_rule" {
  for_each = var.target_ports

  name = "${var.name}-lb-forwarding-rule-${each.key}"

  ip_protocol = "TCP"
  port_range  = each.value
  ip_address  = var.static_ip

  target = google_compute_target_ssl_proxy.default[each.key].self_link
}

resource "google_compute_backend_service" "backend_service" {
  for_each = var.target_ports

  name          = "${var.name}-lb-backend-service-${each.key}"
  port_name     = each.key
  protocol      = "TCP"
  timeout_sec   = var.proxy_connection_timeout_seconds
  health_checks = [var.health_check]

  backend {
    group                        = var.instance_group
    balancing_mode               = "CONNECTION"
    max_connections_per_instance = var.max_connections_per_instance
  }
}