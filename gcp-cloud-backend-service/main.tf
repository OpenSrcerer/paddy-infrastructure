resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  for_each = var.target_ports

  name = "${var.name}-lb-forwarding-rule-${each.key}"

  ip_protocol = var.service_protocol
  port_range  = each.value
  ip_address  = var.static_ip

  target = var.proxy
}

resource "google_compute_backend_service" "backendservice" {
  for_each = var.target_ports

  name          = "${var.name}-lb-backend-service-${each.key}"
  port_name     = each.key
  protocol      = var.service_protocol
  timeout_sec   = var.proxy_connection_timeout_seconds # Timeout for all MQTT messages
  health_checks = [var.health_check]

  backend {
    group                        = var.group_manager
    balancing_mode               = "CONNECTION"
    max_connections_per_instance = var.max_connections_per_instance
  }
}