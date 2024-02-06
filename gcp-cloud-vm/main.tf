data "template_file" "init" {
  template = file("${path.module}/../vm-startup-scripts/auth-startup-script.sh")
}

resource "google_compute_address" "internal_ip" {
  name         = "${var.name}-vm-instance-internal-ip"
  address_type = "INTERNAL"
  address      = "10.0.0.2"
}

resource "google_compute_instance" "default" {
  name                      = "${var.name}-vm-instance"
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
    network_ip = google_compute_address.internal_ip.address

    access_config {
      // auto assigned external ip
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