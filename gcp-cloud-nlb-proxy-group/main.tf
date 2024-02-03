resource "google_compute_backend_service" "backendservice" {
  name          = "${var.name}-lb-backend-service"
  port_name     = "mqtt"
  protocol      = "TCP"
  timeout_sec   = 600 # Timeout for all MQTT messages
  health_checks = [google_compute_health_check.tcp_health_check.self_link]


  backend {
    group          = google_compute_instance_group_manager.default.instance_group
    balancing_mode = "CONNECTION"
  }
}

resource "google_compute_health_check" "tcp_health_check" {
  name                = "${var.name}-tcp-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  tcp_health_check {
    port = "1883"
  }
}

resource "google_compute_global_address" "static" {
  name = "${var.name}-ip-address"
}

resource "google_compute_target_tcp_proxy" "default" {
  name            = "${var.name}-target-tcp-proxy"
  backend_service = google_compute_backend_service.backendservice.self_link
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name        = "${var.name}-lb-forwarding-rule"
  ip_protocol = "TCP"
  port_range  = "1883"
  ip_address  = google_compute_global_address.static.self_link

  target = google_compute_target_tcp_proxy.default.self_link
}

resource "google_compute_instance_group_manager" "default" {
  name = "${var.name}-instance-group"

  base_instance_name = var.name
  zone               = var.zone

  version {
    instance_template = var.instance_template
  }

  named_port {
    name = "mqtt"
    port = 1883
  }

  target_size = var.replicas
}