data "template_file" "init" {
  template = var.startup_script
}

resource "google_compute_address" "internal_ip" {
  name         = "${var.name}-vm-instance-internal-ip"
  address_type = "INTERNAL"
  address      = var.internal_ip
}

resource "google_compute_instance" "default" {
  name                      = "${var.name}-vm-instance"
  machine_type              = var.instance_type
  zone                      = var.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      size  = var.disk_size
      image = var.image
    }
  }

  network_interface {
    network    = var.network_name
    network_ip = google_compute_address.internal_ip.address

    access_config {
      nat_ip = ""
      network_tier = "STANDARD"
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
    backend_mqtt_host               = var.backend_mqtt_host
    backend_mqtt_port               = var.backend_mqtt_port
    backend_mqtt_device_read_topic  = var.backend_mqtt_device_read_topic
    backend_mqtt_authentication_key = var.backend_mqtt_authentication_key
    backend_mqtt_scheduler_events   = var.backend_mqtt_scheduler_events
    backend_auth_service_url        = var.backend_auth_service_url
    backend_db_uri                  = var.backend_db_uri
    backend_db_user                 = var.backend_db_user
    backend_db_password             = var.backend_db_password
  }
}