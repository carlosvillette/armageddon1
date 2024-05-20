resource "google_compute_subnetwork" "america1" {
  name          =  "public-subnet-america1"
  ip_cidr_range = "172.16.1.0/24"
  network       = google_compute_network.vpc.name #need to edit
  region        = "us-east1"
  purpose = "GLOBAL_MANAGED_PROXY"
  role = "ACTIVE"
  lifecycle {
    ignore_changes = [ ipv6_access_type ]
  }
}

resource "google_compute_subnetwork" "america2" {
  name          =  "public-subnet-america2"
  ip_cidr_range = "172.16.2.0/24"
  network       = google_compute_network.vpc.name #need to edit
  region        = "us-east4"
  purpose = "GLOBAL_MANAGED_PROXY"
  role = "ACTIVE"
  lifecycle {
    ignore_changes = [ ipv6_access_type ]
  }
}