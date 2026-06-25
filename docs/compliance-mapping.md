# Compliance Mapping

> 📐 = the mapped control is org-gated reference architecture (not deployed on the
> consumer-account sandbox). See [`deployment-status.md`](deployment-status.md).

| Requirement | Standard | SENTINEL-X Control |
|-------------|----------|--------------------|
| Audit logging of all privileged actions | PCI-DSS 10.2 | Cloud Audit Logs -> BigQuery sink |
| Least privilege access | PCI-DSS 7.1 | IAM Analyzer (deployed) + 📐 IAM Deny policies |
| Encryption in transit and at rest | PCI-DSS 3.4, 4.1 | Cloud KMS + CMEK |
| Incident detection and response | SOC 2 CC7.2 | Cloud Functions SOAR (deployed) + 📐 Chronicle |
| Change management controls | SOC 2 CC8.1 | CI/CD + Binary Authorization |
| Network segmentation | PCI-DSS 1.3 | Subnets (deployed) + 📐 VPC Service Controls |

## Objective -> control type -> source phase

| Objective | Control Type | Phase |
|-----------|--------------|-------|
| Full audit log visibility into BigQuery | Detective | 2 |
| Zero long-lived SA keys in production | Preventive | 5 |
| Least-privilege IAM across all principals | Preventive | 4 |
| Detect privilege escalation within 60s | Detective | 7, 8 |
| Block data exfil even with valid credentials | Preventive | 9 |
| Auto-remediate public buckets in <30s | Corrective | 14 |
| Only signed containers can deploy | Preventive | 11 |
| IaC scanned for misconfigs before apply | Preventive | 12 |
