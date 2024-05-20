resource "google_compute_network" "vpc" {
  name = "vpc-network"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}


resource "google_compute_firewall" "allow-internal-http" {
  name    = "allow-internal-http"
  network = "${google_compute_network.vpc.name}"
  
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  
  source_ranges = [ "172.16.1.0/24",
                    "172.16.2.0/24",
                    "10.0.11.0/24"
  ]
}


resource "google_compute_firewall" "bastion1" {
  name    = "http-bastion"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = [ "0.0.0.0/0"] # the logic here is that the Europe VM does not have a public IP, so even though this allows traffic everywhere, only through America can the instance be accessed
}

resource "google_compute_firewall" "rdp" {
  name    = "rdp-bastion"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = [ "192.168.1.0/24", "35.235.240.0/20" ]
}

resource "google_compute_firewall" "rdp-deny" {
  name    = "rdp-bastion-deny"
  network = "${google_compute_network.vpc.name}"
  
  deny {
    protocol = "tcp"
    ports = [ "80","22" ]
  }
  source_ranges = [ "192.168.1.0/24" ]
}

resource "google_compute_firewall" "fw_healthcheck" {
  name          = "gl7-ilb-fw-allow-hc"
  direction     = "INGRESS"
  network       = google_compute_network.vpc.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
  allow {
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "fw_ilb_to_backends" {
  name          = "fw-ilb-to-fw"
  network       = google_compute_network.vpc.id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "fw_backends" {
  name          = "gl7-ilb-fw-allow-ilb-to-backends"
  direction     = "INGRESS"
  network       = google_compute_network.vpc.id
  source_ranges = [google_compute_subnetwork.america1.ip_cidr_range, google_compute_subnetwork.america2.ip_cidr_range]
  target_tags   = ["http-server"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}