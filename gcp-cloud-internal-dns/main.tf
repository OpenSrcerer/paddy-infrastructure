resource "google_dns_managed_zone" "private" {
    name        = "${var.name}-dns-zone"
    dns_name    = "${var.domain_name}."
    visibility  = "private"

    private_visibility_config {
        networks {
            network_url = var.network
        }
    }
}

resource "google_dns_record_set" "private" {
    for_each = var.dns_records

    name         = "${each.value}.${var.domain_name}."
    type         = "A"
    ttl          = 300
    managed_zone = google_dns_managed_zone.private.name
    rrdatas      = [each.key]
}