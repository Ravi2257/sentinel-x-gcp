resource "google_monitoring_notification_channel" "email" {
  project      = var.project_id
  display_name = "SENTINEL-X Security Alerts"
  type         = "email"
  labels       = { email_address = var.notification_email }
}

resource "google_logging_metric" "iam_owner_grant" {
  project = var.project_id
  name    = "sentinel_iam_owner_grant"
  filter  = <<-EOT
    protoPayload.methodName="SetIamPolicy"
    protoPayload.serviceData.policyDelta.bindingDeltas.role="roles/owner"
  EOT
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "iam_owner_grant" {
  project      = var.project_id
  display_name = "[CRITICAL] Owner Role Granted"
  combiner     = "OR"
  conditions {
    display_name = "Owner role grant detected"
    condition_threshold {
      filter          = "resource.type=\"global\" AND metric.type=\"logging.googleapis.com/user/sentinel_iam_owner_grant\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }
  notification_channels = [google_monitoring_notification_channel.email.id]
  alert_strategy { notification_rate_limit { period = "300s" } }
}
