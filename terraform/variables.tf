variable "project_id" {
  description = "GCP project ID for SENTINEL-X deployment"
  type        = string
}

variable "region" {
  description = "Primary GCP region"
  type        = string
  default     = "us-central1"
}

variable "alert_email" {
  description = "Email for security alert notifications"
  type        = string
}

variable "bq_audit_dataset" {
  description = "BigQuery dataset ID for audit logs"
  type        = string
  default     = "sentinel_audit"
}

variable "corp_cidr" {
  description = "Corporate IP CIDR for IAP and firewall rules"
  type        = string
  default     = "10.0.0.0/8"
}
