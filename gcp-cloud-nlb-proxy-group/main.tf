resource "google_compute_global_address" "static" {
  name = "${var.name}-ip-address"
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "${var.name}-ssl-cert"

  managed {
    domains = [var.ssl_certificate_domain]
  }
}

# ----- BY PORT CONFIGURATION -----
# [INSECURE TCP CONFIG]
resource "google_compute_target_tcp_proxy" "default" {
  for_each = var.tcp_target_ports

  name            = "${var.name}-target-tcp-proxy-${each.key}"
  backend_service = google_compute_backend_service.backendservice[each.key].self_link
}

module "backend_service_tcp" {
  source = "../gcp-cloud-backend-service"

  target_ports     = var.tcp_target_ports
  service_protocol = "TCP"
  proxy            = google_compute_target_tcp_proxy.default.self_link
  health_check     = google_compute_health_check.tcp_health_check.self_link
  group_manager    = google_compute_instance_group_manager.default.self_link
  static_ip        = google_compute_global_address.static.self_link
}

# [SECURE TLS CONFIG]
resource "google_compute_target_ssl_proxy" "default" {
  for_each = var.tcp_target_ports

  name             = "${var.name}-target-tcp-proxy-${each.key}"
  backend_service  = google_compute_backend_service.backendservice[each.key].self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.default.self_link]
}

module "backend_service_tls" {
  source = "../gcp-cloud-backend-service"

  target_ports     = var.tls_target_ports
  service_protocol = "TCP"
  proxy            = google_compute_target_tcp_proxy.default.self_link
  health_check     = google_compute_health_check.tcp_health_check.self_link
  group_manager    = google_compute_instance_group_manager.default.self_link
  static_ip        = google_compute_global_address.static.self_link
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
    for_each = var.target_ports

    content {
      name = named_port.key
      port = named_port.value
    }
  }

  target_size = var.replicas
}