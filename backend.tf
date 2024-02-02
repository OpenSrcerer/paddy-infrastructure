terraform {
  backend "gcs" {
    bucket = "paddy-tf-state-bucket"
    prefix = "terraform/state"
  }
}