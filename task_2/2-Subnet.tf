resource "google_compute_subnetwork" "subnet" {
  name          =  "public-subnet"
  ip_cidr_range = "10.0.0.0/8"
  network       = google_compute_network.vpc.name
  region        = "us-central1"
}