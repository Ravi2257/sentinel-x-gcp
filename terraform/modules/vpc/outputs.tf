output "vpc_id" {
  value = google_compute_network.sentinel_vpc.id
}
output "app_subnet_id" {
  value = google_compute_subnetwork.app_subnet.id
}
