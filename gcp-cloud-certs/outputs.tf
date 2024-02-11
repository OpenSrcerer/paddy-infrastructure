output "managed_ssl_cert" {
  value = google_compute_managed_ssl_certificate.default.self_link
}

output "self_ssl_cert" {
  value = google_compute_ssl_certificate.default.self_link
}