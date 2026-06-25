provider "google" {
  project = var.project_id
  region  = var.region
}

module "vpc" {
  source     = "./modules/vpc"
  project_id = var.project_id
  region     = var.region
  corp_cidr  = var.corp_cidr
}

module "iam" {
  source     = "./modules/iam"
  project_id = var.project_id
}

module "security" {
  source     = "./modules/security"
  project_id = var.project_id
  region     = var.region
}

module "logging" {
  source     = "./modules/logging"
  project_id = var.project_id
  bq_dataset = var.bq_audit_dataset
  kms_key_id = module.security.bq_kms_key_id
}

module "monitoring" {
  source             = "./modules/monitoring"
  project_id         = var.project_id
  notification_email = var.alert_email
}
