# SENTINEL-X Threat Model

## Organization scenario
FinanceCore Technologies - a Series B fintech processing ~$500M/month in
transactions on GCP. 200 employees, fully remote engineering. Subject to
PCI-DSS Level 2 and an in-progress SOC 2 Type II audit.

## Threat actors & likelihood

| Threat Category | Threat Actor | Likelihood | Impact |
|-----------------|--------------|------------|--------|
| External Attack | Nation-state / criminal | Medium | Critical |
| Supply Chain | Compromised dependency | Medium | High |
| Credential Theft | Phishing / OSINT | High | Critical |
| Insider Threat | Disgruntled engineer | Low | High |
| Misconfiguration | Developer error | Very High | High |
| API Abuse | Automated scraper | High | Medium |

## Attack surface
- IAM service accounts with exported JSON keys
- Public-facing Cloud Run endpoints (external ingress)
- BigQuery datasets accessible without VPC Service Controls
- GitHub Actions pipelines with excessive GCP permissions
- Container images pulled from unverified registries
- Cloud Storage buckets misconfigured as public
- GKE nodes with default service accounts (Editor role)

## STRIDE applied to a Cloud Storage bucket
- **S**poofing: attacker impersonates a legitimate SA via key theft
- **T**ampering: attacker modifies stored objects (ransomware)
- **R**epudiation: attacker deletes audit logs / log sinks (detection D-sink)
- **I**nformation disclosure: public bucket exposes data (D2 + auto-remediation)
- **D**enial of service: attacker fills bucket to drive cost
- **E**levation of privilege: attacker gains SA token with bucket admin role

## Security objectives -> controls
See `compliance-mapping.md` for the full control-to-standard mapping.
