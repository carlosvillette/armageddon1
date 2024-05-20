terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.28.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = "burnished-ether-417100"
  credentials = "../burnished-ether-417100-069d8826cf19.json"
}