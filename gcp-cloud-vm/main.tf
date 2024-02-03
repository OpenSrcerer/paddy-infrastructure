data "template_file" "init" {
  template = file("${path.module}/start_docker.sh")
}

resource "google_compute_instance" "default" {
  name                      = var.name
  count                     = var.amount
  machine_type              = "e2-small"
  zone                      = "europe-west6-a"
  allow_stopping_for_update = false

  metadata = {
    backend_mqtt_host = var.backend_mqtt_host
    backend_mqtt_port = var.backend_mqtt_port
    backend_mqtt_subscriptions = var.backend_mqtt_subscriptions
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-pro-cloud/ubuntu-pro-2204-lts"
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
}