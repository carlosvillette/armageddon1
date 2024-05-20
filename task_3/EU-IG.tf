/*
resource "google_compute_instance_group" "eu-http" {
    name        = "europe-resources"
    zone        = "europe-central2-a"
    network = google_compute_network.vpc.id

    named_port {
        name = "http"
        port    = "80"
    }

    instances = [
        "${google_compute_instance.vm.self_link}"
    ]

    lifecycle {
      create_before_destroy = true
    }


}

resource "google_compute_instance_group" "eu-rdp" {
    name        = "europe-resources"
    zone        = "europe-central2-a"
    network = google_compute_network.vpc.id

    named_port {
        name = "rdp"
        port    = "3389"
    }

    instances = [
        "${google_compute_instance.windows.self_link}"
    ]

    lifecycle {
      create_before_destroy = true
    }


}
*/