resource "google_compute_network" "asian_network" {
  name                    = "asian-network"
  auto_create_subnetworks = false
  #routing_mode            = "GLOBAL"
  #mtu                     = 1460
}

resource "google_compute_subnetwork" "asian_subnet" {
  name          = "asian-subnet"
  depends_on = [ google_compute_network.asian_network ]
  ip_cidr_range = "192.168.0.0/24"
  region        = var.asian_region
  network       = google_compute_network.asian_network.id
  private_ip_google_access = true
}

resource "google_compute_firewall" "asia" {
  name    = "asia"
  network = google_compute_network.asian_network.id
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  #source_tags =  ["vpn"]
  #source_ranges = ["10.157.0.0/24", "35.235.240.0/20"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_vpn_gateway" "asian_vpn_gateway" {
  name    = "asia-vpn-gateway"
  region  = var.asian_region
  network = google_compute_network.asian_network.id
}

resource "google_compute_address" "asian_vpn_gateway_ip" {
  name   = "asia-vpn-gateway-ip"
  region = var.asian_region
  #network = google_compute_network.asian_network
}

resource "google_compute_forwarding_rule" "asian_esp" {
  name        = "asia-esp"
  region      = var.asian_region
  ip_protocol = "ESP"
  ip_address  = google_compute_address.asian_vpn_gateway_ip.address
  target      = google_compute_vpn_gateway.asian_vpn_gateway.self_link
  depends_on = [ google_compute_vpn_gateway.asian_vpn_gateway]
}

resource "google_compute_forwarding_rule" "asian_udp500" {
  name        = "asia-udp500"
  region      = var.asian_region
  ip_protocol = "UDP"
  ip_address  = google_compute_address.asian_vpn_gateway_ip.address
  port_range  = "500"
  target      = google_compute_vpn_gateway.asian_vpn_gateway.self_link
  depends_on = [ google_compute_vpn_gateway.asian_vpn_gateway]
}

resource "google_compute_forwarding_rule" "asian_udp4500" {
  name        = "asia-udp4500"
  region      = var.asian_region
  ip_protocol = "UDP"
  ip_address  = google_compute_address.asian_vpn_gateway_ip.address
  port_range  = "4500"
  target      = google_compute_vpn_gateway.asian_vpn_gateway.self_link
  depends_on = [ google_compute_vpn_gateway.asian_vpn_gateway]
}

resource "google_compute_vpn_tunnel" "asian_to_europe_tunnel" {
  name                    = "asia-to-europe-tunnel"
  region                  = var.asian_region
  target_vpn_gateway      = google_compute_vpn_gateway.asian_vpn_gateway.id
  peer_ip                 = google_compute_address.european_vpn_gateway_ip.address
  shared_secret           = var.vpn_shared_secret
  ike_version             = 2
  local_traffic_selector  = [google_compute_subnetwork.asian_subnet.ip_cidr_range]
  #local_traffic_selector  = ["192.168.11.0/24"]
  remote_traffic_selector = [google_compute_subnetwork.european_subnet.ip_cidr_range]
  depends_on = [
    google_compute_forwarding_rule.asian_esp,
    google_compute_forwarding_rule.asian_udp500
  ]
}

resource "google_compute_route" "ap2eu" {
  name = "ap-hop-2-eu"
  network = google_compute_network.asian_network.id
  dest_range = google_compute_subnetwork.european_subnet.ip_cidr_range
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.asian_to_europe_tunnel.id
  priority = 100
}

resource "google_project_service" "cloudresourcemanager" {
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_compute_instance" "asia-instance" {
  depends_on = [ google_compute_subnetwork.asian_subnet ]
  name         = "asia-instance"
  machine_type = var.instance_type
  zone         = "${var.asian_region}-b"
  boot_disk {
    initialize_params {
      image = var.instance_image_windows
    }
  }

  network_interface {
    network = google_compute_network.asian_network.id
    subnetwork = google_compute_subnetwork.asian_subnet.id
    access_config {
      // Ephemeral IP, no external IP
    }
  }

}
