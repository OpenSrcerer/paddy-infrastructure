data "template_file" "init" {
  template = file("${path.module}/../vm-startup-scripts/auth-startup-script.sh")
}

resource "google_compute_instance" "default" {
  name                      = "${var.name}-vm-instance"
  count                     = var.amount
  machine_type              = "e2-small"
  zone                      = var.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = var.network_name
    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = data.template_file.init.rendered

  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-ro"]
  }

  lifecycle {
    create_before_destroy = true
  }

  metadata = {
    backend_mqtt_authentication_key = var.backend_mqtt_authentication_key
  }
}