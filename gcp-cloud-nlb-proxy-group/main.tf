resource "google_compute_backend_service" "backendservice" {
  name            = "${var.name}-lb-backend-service"
  protocol        = "TCP"
  timeout_sec     = 10
  health_checks   = [google_compute_health_check.tcp_health_check.self_link]

  backend {
    group = google_compute_instance_group_manager.default.instance_group
  }
}

resource "google_compute_health_check" "tcp_health_check" {
  name               = "${var.name}-tcp-health-check"
  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "1883"
  }
}

resource "google_compute_address" "static" {
  name = "${var.name}-ip-address"
}

resource "google_compute_target_tcp_proxy" "default" {
  name            = "${var.name}-target-tcp-proxy"
  service         = google_compute_backend_service.backendservice.self_link
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "${var.name}-lb-forwarding-rule"
  ip_protocol= "TCP"
  port_range = "1883"
  ip_address = google_compute_address.static.address

  target = google_compute_target_tcp_proxy.default.self_link
}

resource "google_compute_instance_group_manager" "default" {
  name                = "${var.name}-instance-group"
  base_instance_name  = var.name
  zone                = var.zone

  version {
    instance_template   = var.instance_template
  }

  target_size = var.replicas
}