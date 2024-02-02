terraform {
  backend "gcs" {
    credentials = "service-account-credentials.json"
    bucket      = "paddy-tf-state-bucket"
    prefix      = "terraform/state"
  }
}