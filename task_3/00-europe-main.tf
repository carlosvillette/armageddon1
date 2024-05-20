provider "google" {
  credentials = var.credentials
  project     = var.project_id
  region      = var.european_region
}

# European Network and Subnetwork
resource "google_compute_network" "european_network" {
  name                    = "european-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "european_subnet" {
  name          = "european-subnet"
  depends_on = [ google_compute_network.european_network ]
  ip_cidr_range = "10.150.0.0/24"
  region        = var.european_region
  network       = google_compute_network.european_network.id
  private_ip_google_access = true
}

resource "google_service_account" "europe" {
  account_id = "europe"
  display_name = "VM service account"
}

# European Compute Engine
resource "google_compute_instance" "european_instance" {
  depends_on = [ google_compute_network.european_network , google_compute_subnetwork.european_subnet ]
  name         = "european-instance"
  machine_type = var.instance_type
  zone         = "${var.european_region}-b"

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    network    = google_compute_network.european_network.id
    subnetwork = google_compute_subnetwork.european_subnet.id
    access_config {
      // Ephemeral IP, no external IP
    }
  }

  metadata_startup_script = file("${path.module}/startup-script.sh")
}

# Firewall rules to allow only internal traffic on port 80
resource "google_compute_firewall" "eu_http" {
  name    = "internal-http"
  network = google_compute_network.european_network.id
  allow {
    protocol = "tcp"
    ports    = ["80","22","3389"]
  }
  allow {
    protocol = "icmp"
  }
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  source_ranges = [google_compute_subnetwork.american_subnet1.ip_cidr_range,google_compute_subnetwork.american_subnet2.ip_cidr_range, "192.168.0.0/16","0.0.0.0/0"]
  depends_on = [ google_compute_network.european_network ]
}

resource "google_compute_vpn_gateway" "european_vpn_gateway" {
  name    = "european-vpn-gateway"
  region  = var.european_region
  network = google_compute_network.european_network.id
}

resource "google_compute_address" "european_vpn_gateway_ip" {
  name   = "european-vpn-gateway-ip"
  region = var.european_region
}

