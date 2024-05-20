resource "google_compute_subnetwork" "europe" {
  name          =  "private-subnet-europe"
  ip_cidr_range = "10.0.11.0/24"
  network       = google_compute_network.vpc.name #need to edit
  region        = "europe-central2"
  private_ip_google_access = true
}

