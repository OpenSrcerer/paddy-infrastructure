# ---- GLOBAL LOAD BALANCER ----
resource "google_compute_target_ssl_proxy" "global_proxy" {
  for_each = var.target_ports

  name             = "${var.name}-global-target-ssl-proxy-${each.key}"
  backend_service  = google_compute_backend_service.backend_service[each.key].self_link
  ssl_certificates = var.ssl_certificates

  ssl_policy = var.security_policy
}

resource "google_compute_global_forwarding_rule" "tcp_global_forwarding_rule" {
  for_each = var.target_ports

  name = "${var.name}-global-lb-forwarding-rule-${each.key}"

  ip_protocol = "TCP"
  port_range  = each.value
  ip_address  = var.global_static_ip

  target = google_compute_target_ssl_proxy.global_proxy[each.key].self_link
}
# ------------------------------

# ---- INTERNAL LOAD BALANCER ----
resource "google_compute_target_tcp_proxy" "internal_proxy" {
  for_each = var.target_ports

  name            = "${var.name}-internal-target-ssl-proxy-${each.key}"
  backend_service = google_compute_backend_service.backend_service[each.key].self_link
}

resource "google_compute_forwarding_rule" "tcp_internal_forwarding_rule" {
  for_each = var.target_ports

  region = var.region
  name   = "${var.name}-intlb-fwd-rule-${each.key}"

  ip_protocol = "TCP"
  port_range  = each.value
  ip_address  = var.internal_static_ip

  target = google_compute_target_tcp_proxy.internal_proxy[each.key].self_link
}
# ------------------------------

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