output "bq_kms_key_id" {
  value = google_kms_crypto_key.bq_key.id
}
output "armor_policy_id" {
  value = google_compute_security_policy.armor.id
}
