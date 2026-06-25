# PB-003 - Storage Bucket Public Exposure

## IDENTIFY
- SCC finding PUBLIC_BUCKET_ACL fires.
- Log Explorer: storage.setIamPermissions with allUsers.
- Detection D2 returns rows.

## CONTAIN
- Auto-remediation Cloud Function should fire within ~30s.
- Manual: `gsutil iam ch -d allUsers:objectViewer gs://BUCKET`.
- Enable Uniform Bucket-Level Access.

## ERADICATE
- Audit access logs to determine if data was downloaded.
- If PII accessed: start breach notification process.
- Scan all buckets for similar misconfig (IAM Analyzer).
- Add Org Policy storage.publicAccessPrevention=enforced.

## RECOVER
- Rotate any credentials that may have been in the bucket.
- Run Cloud DLP to classify what was exposed.

## LESSONS LEARNED
- Org Policy publicAccessPrevention prevents the whole class.
- VPC-SC adds defense in depth.
