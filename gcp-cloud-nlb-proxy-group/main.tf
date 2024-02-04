resource "google_compute_global_address" "static" {
  name = "${var.name}-ip-address"
}

resource "google_compute_target_tcp_proxy" "default" {
  name            = "${var.name}-target-tcp-proxy"
  backend_service = google_compute_backend_service.backendservice.self_link
}


resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  for_each = var.target_ports

  name        = "${var.name}-lb-forwarding-rule-${each.key}"
  ip_protocol = "TCP"
  port_range  = each.value
  ip_address  = google_compute_global_address.static.self_link

  target = google_compute_target_tcp_proxy.default.self_link
}

resource "google_compute_backend_service" "backendservice" {
  name          = "${var.name}-lb-backend-service"
  port_name     = "mqtt"
  protocol      = "TCP"
  timeout_sec   = var.proxy_connection_timeout_seconds # Timeout for all MQTT messages
  health_checks = [google_compute_health_check.tcp_health_check.self_link]

  backend {
    group                        = google_compute_instance_group_manager.default.instance_group
    balancing_mode               = "CONNECTION"
    max_connections_per_instance = var.max_connections_per_instance
  }
}

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
    for_each = var.target_ports

    content {
      name = named_port.key
      port = named_port.value
    }
  }

  target_size = var.replicas
}