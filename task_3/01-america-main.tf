# American Networks and Subnetworks
resource "google_compute_network" "american_network1" {
  name                    = "american-network1"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "american_subnet1" {
  name          = "american-subnet1"
  depends_on = [ google_compute_network.american_network1 ]
  ip_cidr_range = "172.16.1.0/24"
  region        = var.american_region1
  network       = google_compute_network.american_network1.id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "american_subnet2" {
  name          = "american-subnet2"
  depends_on = [ google_compute_network.american_network1 ]
  ip_cidr_range = "172.16.2.0/24"
  region        = var.american_region2
  network       = google_compute_network.american_network1.id
  private_ip_google_access = true
}

resource "google_service_account" "america" {
  account_id = "america"
  display_name = "VM service account"
}

# Peering between American and European Networks
resource "google_compute_network_peering" "us_to_eu_peering1" {
  name         = "us-to-eu-peering1"
  network      = google_compute_network.american_network1.id
  peer_network = google_compute_network.european_network.id
}

resource "google_compute_network_peering" "eu_to_us_peering1" {
  name         = "eu-to-us-peering1"
  network      = google_compute_network.european_network.id
  peer_network = google_compute_network.american_network1.id
}

resource "google_compute_firewall" "internal_http1" {
  name    = "internal-http1"
  network = google_compute_network.american_network1.id
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["80","22"]
  }
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  #source_tags =  ["vpn"]
  #source_ranges = ["10.157.0.0/24", "35.235.240.0/20"]
  source_ranges = [google_compute_subnetwork.european_subnet.ip_cidr_range, "35.235.240.0/20"]
    #target_tags = ["us-instance1","iap-ssh-allowed"]
}
/*
resource "google_compute_firewall" "ssh" {
  name    = "ssh"
  network = google_compute_network.american_network1.id
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
 
  source_ranges = ["0.0.0.0/0"]
}
*/
resource "google_compute_instance" "us-instance1" {
  depends_on = [ google_compute_subnetwork.american_subnet1 , google_compute_network.american_network1]
  name         = "us-instance1"
  machine_type = var.instance_type
  zone         = "${var.american_region1}-b"

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    network = google_compute_network.american_network1.id
    subnetwork = google_compute_subnetwork.american_subnet1.id
    access_config {
      // Ephemeral IP, no external IP
    }
  }


  #tags = ["us1", "vpn", "iam-ssh-allowed"]
}





resource "google_compute_firewall" "am_http" {
  name    = "america"
  network = google_compute_network.american_network1.id
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["80","22"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  #source_tags =  ["vpn"]
  #source_ranges = ["10.157.0.0/24", "35.235.240.0/20"]
  source_ranges = ["0.0.0.0/0",google_compute_subnetwork.european_subnet.ip_cidr_range]
  #target_tags = ["us-instance2","iap-ssh-allowed"]
}
/*
resource "google_compute_instance" "us-instance2" {
  depends_on = [ google_compute_subnetwork.american_subnet2 ]
  name         = "us-instance2"
  machine_type = var.instance_type
  zone         = "${var.american_region2}-b"
  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    network = google_compute_network.american_network2.id
    subnetwork = google_compute_subnetwork.american_subnet2.id
    access_config {
      // Ephemeral IP, no external IP
    }
  }

  tags = ["us2", "vpn", "iam-ssh-allowed"]
}
*/