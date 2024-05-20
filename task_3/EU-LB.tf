/*
Copyright 2019 Google LLC
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    https://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#<!--* freshness: { owner: 'ttaggart@google.com' reviewed: '2019-10-01' } *-->

resource "google_compute_health_check" "http-basic-check" {
  name = "http-basic-check"
  project = "burnished-ether-417100"

  timeout_sec         = 2
  check_interval_sec  = 3
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
  /* Project is already created, so it shouldn't be needed
  depends_on = [
    "google_project_services.iap_connect_vpc"
  ]
  */
}

resource "google_compute_backend_service" "http-map-backend-service" {
  name          = "http-map-backend-service"
  protocol      = "HTTP"
  port_name     = "http"
  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks = [google_compute_health_check.http-basic-check.id]
/*
  backend {
    group = "${google_compute_instance_group.us-resources-w.self_link}"
  }
  */
  
    backend {
    group = google_compute_region_instance_group_manager.mig_a.instance_group
    #balancing_mode  = "UTILIZATION" NOT NEEDED SINCE NOT USING HTTPS
    capacity_scaler = 1.0
  }  
}

resource "google_compute_url_map" "web-map" {
  name        = "web-map"
  default_service = google_compute_backend_service.http-map-backend-service.id
}

resource "google_compute_target_http_proxy" "http-lb-proxy" {
  name        = "http-lb-proxy"
  url_map     = google_compute_url_map.web-map.id
}

#THE FORWARDING RULES WON'T WORK BECAUSE THE PROXY SUBNET IS IN AN AMERICAN REGION WHILE THE BACKEND IS IN AN ASIAN REGION. THEY MUST BE IN THE SAME REGION
resource "google_compute_global_forwarding_rule" "http-rule1" {
  name       = "http-cr-rule1"
  target     = google_compute_target_http_proxy.http-lb-proxy.id
  port_range = "80"
  network = google_compute_network.vpc.id
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  #subnetwork = google_compute_subnetwork.america1.id
  subnetwork = google_compute_subnetwork.europe.id
  depends_on = [ google_compute_subnetwork.america1 ]
  #allow_global_access = true
  ip_address = "10.0.11.99" #NEEDED THIS TO STOP FORWARDING RULE FAILURE
}

resource "google_compute_global_forwarding_rule" "http-rule2" {
  name       = "http-cr-rule2"
  target     = google_compute_target_http_proxy.http-lb-proxy.id
  port_range = "80"
  network = google_compute_network.vpc.id
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  subnetwork = google_compute_subnetwork.europe.id
  depends_on = [ google_compute_subnetwork.america2 ]
  #subnetwork = google_compute_subnetwork.america2.id
  ip_address = "10.0.11.100" #NEEDED THIS TO STOP FORWARDING RULE FAILURE
}
