resource "google_compute_network" "default" {
  name                    = var.name
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "firewall-rule" {
  name    = "paddy-allowed-ports"
  network = google_compute_network.default.name
  allow {
    protocol = "tcp"
    ports    = var.allowed_ports_tcp_anyip
  }
  source_ranges = ["0.0.0.0/0"]
}