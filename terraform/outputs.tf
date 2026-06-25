output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "SENTINEL-X VPC network ID"
}

output "bq_dataset" {
  value       = module.logging.dataset_id
  description = "BigQuery audit dataset"
}

output "alert_topic" {
  value       = module.logging.alert_topic_id
  description = "Pub/Sub topic for security alerts"
}

output "soar_sa_email" {
  value       = module.iam.soar_sa_email
  description = "Service account used by Cloud Functions for auto-remediation"
}
