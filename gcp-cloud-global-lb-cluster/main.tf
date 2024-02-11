module "backend_service" {
  source = "../gcp-cloud-backend-service"

  name                             = "${var.name}-backend-service"
  static_ip                        = var.static_external_ip
  instance_group                   = google_compute_instance_group_manager.default.instance_group
  max_connections_per_instance     = var.max_connections_per_instance
  health_check                     = google_compute_health_check.tcp_health_check.self_link
  proxy_connection_timeout_seconds = var.proxy_connection_timeout_seconds

  target_ports     = var.tcp_target_ports
  ssl_certificates = var.ssl_certificates
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
    type                    = "PROACTIVE"
    minimal_action          = "RECREATE"
    replacement_method      = "RECREATE"
    max_unavailable_percent = 100
  }

  version {
    instance_template = var.instance_template
  }

  dynamic "named_port" {
    for_each = var.tcp_target_ports

    content {
      name = named_port.key
      port = named_port.value
    }
  }

  target_size = var.replicas
}