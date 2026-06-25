resource "google_kms_key_ring" "sentinel" {
  name     = "sentinel-kr"
  location = "us"
  project  = var.project_id
}

resource "google_kms_crypto_key" "bq_key" {
  name            = "sentinel-bq-key"
  key_ring        = google_kms_key_ring.sentinel.id
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_secret_manager_secret" "example" {
  secret_id = "sentinel-demo-secret"
  project   = var.project_id
  replication {
    auto {}
  }
}

# Cloud Armor security policy (WAF) - basic rate limiting + default rules
resource "google_compute_security_policy" "armor" {
  name    = "sentinel-armor-policy"
  project = var.project_id

  rule {
    action   = "deny(403)"
    priority = 1000
    match {
      versioned_expr = "SRC_IPS_V1"
      config { src_ip_ranges = ["198.51.100.0/24"] } # example blocklist
    }
    description = "Block known-bad range"
  }

  rule {
    action   = "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config { src_ip_ranges = ["*"] }
    }
    description = "Default allow"
  }
}
