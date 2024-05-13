output "Public-IP" {
  description = "The public IP of the instance"
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "VPC" {
  description = "The name of the VPC"
  value = google_compute_network.vpc.name
}

output "subnet" {
  description = "The subnet of the VM"
  value = google_compute_subnetwork.subnet.name
}

output "Private-IP" {
  description = "The private IP of the instance"
  value = google_compute_instance.vm.network_interface[0].network_ip
}