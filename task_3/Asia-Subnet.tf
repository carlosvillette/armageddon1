resource "google_compute_subnetwork" "asia" {
  name          =  "rdp-subnet-asia"
  ip_cidr_range = "192.168.1.0/24"
  network       = google_compute_network.vpc.name #need to edit
  region        = "asia-east1"
}
