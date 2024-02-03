data "template_file" "init" {
    template = file("${path.module}/start_docker.sh")
}

resource "google_compute_instance_template" "default_template" {
    name_prefix  = "${var.name}-"
    machine_type = "e2-small"
    can_ip_forward = false

    scheduling {
        automatic_restart = true
        on_host_maintenance = "MIGRATE"
        preemptible = false
    }

    disk {
        source_image = "ubuntu-os-pro-cloud/ubuntu-pro-2204-lts"
        auto_delete  = true
        boot         = true
    }

    network_interface {
        network = var.network_name
        access_config {
            // Ephemeral IP
        }
    }

    service_account {
        scopes = ["userinfo-email", "compute-rw", "storage-ro"]
    }

    lifecycle {
        create_before_destroy = true
    }
    
    metadata = {
        backend_mqtt_host          = var.backend_mqtt_host
        backend_mqtt_port          = var.backend_mqtt_port
        backend_mqtt_subscriptions = var.backend_mqtt_subscriptions
    }

    metadata_startup_script = data.template_file.init.rendered
}