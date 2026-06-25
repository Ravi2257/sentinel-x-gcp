resource "google_bigquery_dataset" "audit" {
  dataset_id                 = var.bq_dataset
  location                   = "US"
  project                    = var.project_id
  description                = "SENTINEL-X audit log warehouse"
  delete_contents_on_destroy = true

  dynamic "default_encryption_configuration" {
    for_each = var.kms_key_id == "" ? [] : [1]
    content {
      kms_key_name = var.kms_key_id
    }
  }
}

resource "google_logging_project_sink" "audit_to_bq" {
  name                   = "sentinel-audit-to-bq"
  project                = var.project_id
  destination            = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${var.bq_dataset}"
  filter                 = "logName:\"cloudaudit.googleapis.com\""
  unique_writer_identity = true
  bigquery_options { use_partitioned_tables = true }
}

resource "google_project_iam_member" "sink_bq_writer" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = google_logging_project_sink.audit_to_bq.writer_identity
}

resource "google_pubsub_topic" "alerts" {
  name                       = "sentinel-x-alerts"
  project                    = var.project_id
  message_retention_duration = "86600s"
}

resource "google_logging_project_sink" "audit_to_pubsub" {
  name        = "sentinel-audit-to-pubsub"
  project     = var.project_id
  destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/${google_pubsub_topic.alerts.name}"
  filter      = <<-EOT
    logName:"cloudaudit.googleapis.com/activity"
    (
      protoPayload.methodName="SetIamPolicy"
      OR protoPayload.methodName:"CreateServiceAccount"
      OR protoPayload.methodName:"firewalls.insert"
      OR protoPayload.methodName="storage.setIamPermissions"
    )
  EOT
  unique_writer_identity = true
}

resource "google_pubsub_topic_iam_member" "pubsub_writer" {
  topic   = google_pubsub_topic.alerts.name
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = google_logging_project_sink.audit_to_pubsub.writer_identity
}
