output "external-ip-1" {
  description = "ip value for the proxy to the private subnet"
  value = "http://${google_compute_global_forwarding_rule.http-rule1.ip_address}"
}

output "external-ip-2" {
  description = "ip value for the proxy to the private subnet"
  value = "http://${google_compute_global_forwarding_rule.http-rule2.ip_address}"
}