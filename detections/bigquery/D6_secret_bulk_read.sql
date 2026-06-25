-- Technique: T1552.001 (Credentials from Files) | Severity: HIGH
-- TP: one principal reads >10 distinct secrets within 1 hour (bulk exfil).
-- FP: a legitimate batch deploy reading many secrets (exclude its SA).
SELECT protopayload_auditlog.authenticationInfo.principalEmail AS who,
       COUNT(*) AS secret_reads,
       COUNT(DISTINCT resource.labels.secret_id) AS distinct_secrets
FROM `sentinel_audit.cloudaudit_googleapis_com_data_access`
WHERE protopayload_auditlog.methodName =
      "google.cloud.secretmanager.v1.SecretManagerService.AccessSecretVersion"
  AND timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
GROUP BY who
HAVING distinct_secrets > 10
ORDER BY secret_reads DESC;
