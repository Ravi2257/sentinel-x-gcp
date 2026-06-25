resource "google_compute_network" "sentinel_vpc" {
  name                    = "sentinel-x-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "app_subnet" {
  name                     = "app-subnet"
  ip_cidr_range            = "10.0.2.0/24"
  region                   = var.region
  network                  = google_compute_network.sentinel_vpc.id
  private_ip_google_access = true
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "data_subnet" {
  name                     = "data-subnet"
  ip_cidr_range            = "10.0.3.0/24"
  region                   = var.region
  network                  = google_compute_network.sentinel_vpc.id
  private_ip_google_access = true
}

# Default-deny ingress (allow-list only)
resource "google_compute_firewall" "deny_all_ingress" {
  name      = "sentinel-deny-all-ingress"
  network   = google_compute_network.sentinel_vpc.id
  priority  = 65534
  direction = "INGRESS"
  deny { protocol = "all" }
  source_ranges = ["0.0.0.0/0"]
}

# Allow SSH only from Google IAP range
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "sentinel-allow-iap-ssh"
  network = google_compute_network.sentinel_vpc.id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["iap-ssh"]
}

resource "google_compute_router" "nat_router" {
  name    = "sentinel-nat-router"
  region  = var.region
  network = google_compute_network.sentinel_vpc.id
}

resource "google_compute_router_nat" "cloud_nat" {
  name                               = "sentinel-cloud-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
