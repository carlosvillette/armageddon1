# NAT ROUTER
resource "google_compute_router" "router" {
  name    = "router"
  region  = google_compute_subnetwork.europe.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "router-nat" {
  name                               = "router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  /*
  subnetwork {
    name                             = google_compute_subnetwork.europe.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  */
}