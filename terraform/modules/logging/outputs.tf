output "dataset_id" {
  value = google_bigquery_dataset.audit.dataset_id
}
output "alert_topic_id" {
  value = google_pubsub_topic.alerts.id
}
