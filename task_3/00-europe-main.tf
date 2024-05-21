
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

  #metadata_startup_script = file("${path.module}/startup-script.sh")
  metadata = {
    startup-script = "#Thanks to Remo\n#!/bin/bash\n# Update and install Apache2\napt update\napt install -y apache2\n\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html><body>\n<h2>Welcome to your custom website.</h2>\n<h3>Created with a direct input startup script!</h3>\n<p><b>Instance Name:</b> $(hostname -f)</p>\n<p><b>Instance Private IP Address: </b> $local_ipv4</p>\n<p><b>Zone: </b> $zone</p>\n<p><b>Project ID:</b> $project_id</p>\n<p><b>Network Tags:</b> $network_tags</p>\n</body></html>\nEOF"
  }
}

# Firewall rules to allow only internal traffic on port 80
resource "google_compute_firewall" "eu_http" {
  name    = "internal-http"
  network = google_compute_network.european_network.id
  allow {
    protocol = "tcp"
    ports    = ["22","3389"]
  }
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  allow {
    protocol = "icmp"
  }
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  source_ranges = [google_compute_subnetwork.american_subnet1.ip_cidr_range,google_compute_subnetwork.american_subnet2.ip_cidr_range, "192.168.0.0/16"]
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

