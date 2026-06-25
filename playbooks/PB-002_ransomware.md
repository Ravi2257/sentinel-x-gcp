# PB-002 - Ransomware / Data Destruction

## IDENTIFY
- Unusual volume of storage.objects.delete / bigquery.tables.delete.
- Anomaly detector (z-score) fires on delete volume.
- SCC finding ANOMALOUS_IAM_GRANT or ACCOUNT_HIJACKING.

## CONTAIN
- Revoke the principal's IAM roles immediately.
- Ensure Object Versioning is enabled on all buckets.
- `python scripts/auto_quarantine.py` on affected VMs.
- Block the attacker IP at Cloud Armor.

## ERADICATE
- Restore deleted objects from versioned buckets.
- Restore BigQuery tables from snapshots/backups.
- Audit remaining principals for the same pattern.

## RECOVER
- Restore from the most recent clean backup.
- Verify data integrity (checksums).
- Enable CMEK with KMS key rotation.

## LESSONS LEARNED
- Enable GCS Object Versioning from day 1.
- Schedule BigQuery table snapshots.
- Deploy VPC-SC before the next incident.
