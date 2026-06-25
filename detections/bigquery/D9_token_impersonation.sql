-- Technique: T1550.001 (Use Alternate Authentication Material) | Severity: CRITICAL
-- TP: a principal generates a token/signs for a DIFFERENT service account.
-- FP: an approved impersonation chain (exclude specific caller->target pairs).
SELECT timestamp,
       protopayload_auditlog.authenticationInfo.principalEmail AS caller,
       protopayload_auditlog.resourceName AS target_sa
FROM `sentinel_audit.cloudaudit_googleapis_com_activity`
WHERE protopayload_auditlog.methodName IN
      ("GenerateAccessToken", "SignJwt", "SignBlob")
  AND protopayload_auditlog.authenticationInfo.principalEmail
      != REGEXP_EXTRACT(protopayload_auditlog.resourceName, r"serviceAccounts/(.+)$")
ORDER BY timestamp DESC;
