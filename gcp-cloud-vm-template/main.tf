data "template_file" "init" {
  template = var.startup_script
}

resource "google_compute_instance_template" "default_template" {
  name_prefix    = "${var.name}-"
  machine_type   = var.instance_type
  can_ip_forward = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  disk {
    source_image = "cos-cloud/cos-stable"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = var.network_name

    access_config {
      nat_ip = ""
      network_tier = "STANDARD"
    }
  }

  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-ro"]
  }

  lifecycle {
    create_before_destroy = true
  }

  metadata = {
    backend_mqtt_host              = var.backend_mqtt_host
    backend_mqtt_port              = var.backend_mqtt_port
    backend_mqtt_device_read_topic = var.backend_mqtt_device_read_topic
    backend_mqtt_subscriptions     = var.backend_mqtt_subscriptions
    backend_mqtt_scheduler_events  = var.backend_mqtt_scheduler_events
    backend_auth_service_url       = var.backend_auth_service_url
    backend_db_uri                 = var.backend_db_uri
    backend_db_user                = var.backend_db_user
    backend_db_password            = var.backend_db_password
  }

  metadata_startup_script = data.template_file.init.rendered
}