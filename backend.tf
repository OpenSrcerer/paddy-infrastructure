terraform {
  backend "gcs" {
    bucket = "paddy-infrastructure-tf-state"
    prefix = "terraform/state"
  }
}