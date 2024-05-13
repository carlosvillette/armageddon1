resource "google_compute_network" "vpc" {
  name = "vpc-network"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

resource "google_compute_firewall" "http" {
  name    = "http"
  network = google_compute_network.vpc.name
allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  direction = "INGRESS"
}
resource "google_compute_firewall" "ssh" {
  name    = "ssh"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
  direction = "INGRESS"

  }