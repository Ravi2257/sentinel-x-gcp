# Service account that Cloud Functions use for auto-remediation (SOAR)
resource "google_service_account" "soar" {
  account_id   = "sentinel-soar"
  display_name = "SENTINEL-X SOAR remediation SA"
  project      = var.project_id
}

# Least-privilege roles for remediation actions
resource "google_project_iam_member" "soar_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.soar.email}"
}

resource "google_project_iam_member" "soar_sa_admin" {
  project = var.project_id
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${google_service_account.soar.email}"
}

resource "google_project_iam_member" "soar_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.soar.email}"
}
