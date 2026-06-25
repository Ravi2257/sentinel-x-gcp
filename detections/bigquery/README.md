# BigQuery Detections

Detection-as-code rules that run over exported Cloud Audit Logs. Each `.sql`
file is a standalone detection with a header documenting its MITRE ATT&CK
technique, severity, and true-positive / false-positive criteria.

## Table naming — read before running

These queries reference the **partitioned** table name:

```
`sentinel_audit.cloudaudit_googleapis_com_activity`
`sentinel_audit.cloudaudit_googleapis_com_data_access`
```

That name is produced when the log sink is created with **partitioned tables**
(`use_partitioned_tables = true`), which is how `terraform/modules/logging`
provisions it. Deploy via Terraform and the queries work unchanged.

If instead you create the sink manually **without** `--use-partitioned-tables`,
Cloud Logging writes **date-sharded** tables (`..._activity_20260625`,
`..._activity_20260703`, ...). In that case query the wildcard table by
appending `_*` to the name, e.g. `..._activity_*`. A wildcard will **not** match
a partitioned table (no trailing suffix), so pick the form that matches how your
sink was created — do not mix them.

## Catalog

| ID | File | Technique | Severity | Detects |
|----|------|-----------|----------|---------|
| D1 | D1_owner_role_granted.sql | T1548 | CRITICAL | roles/owner or roles/editor granted on the project |
| D2 | D2_public_bucket.sql | T1530 | CRITICAL | Bucket opened to allUsers / allAuthenticatedUsers |
| D3 | D3_suspicious_login.sql | T1078 | HIGH | API activity from an IP outside the corp allowlist |
| D4 | D4_crypto_mining.sql | T1496 | HIGH | >5 VMs created by one principal in 10 minutes |
| D5 | D5_backdoor_sa.sql | T1136.003 | CRITICAL | SA created + key exported by same actor <=5 min |
| D6 | D6_secret_bulk_read.sql | T1552.001 | HIGH | One principal reads >10 distinct secrets in 1 hour |
| D7 | D7_open_firewall.sql | T1190 | HIGH | Firewall rule opens 22/3389 to 0.0.0.0/0 |
| D8 | D8_binaryauth_violation.sql | T1610 | HIGH | Binary Authorization rejected an unsigned image |
| D9 | D9_token_impersonation.sql | T1550.001 | CRITICAL | Principal mints a token for a different SA |

## Engineering note

D1 parses the IAM `bindingDeltas` array with `UNNEST` and compares typed fields
(`bd.role`, `bd.action`) instead of string-matching the serialized proto. This
is deliberate: a blob `LIKE "%roles/editor%"` also matches revocation (REMOVE)
events and role-name substrings, producing false positives. Prefer structured
parsing over JSON string-matching for any audit-log field that is an array.
