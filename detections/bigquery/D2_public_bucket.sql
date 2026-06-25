-- Technique: T1530 (Data from Cloud Storage Object) | Severity: CRITICAL
-- TP: a bucket IAM policy was changed to grant allUsers/allAuthenticatedUsers.
-- FP: an approved public static-hosting bucket (maintain an allowlist).
SELECT timestamp,
       resource.labels.bucket_name AS bucket,
       protopayload_auditlog.authenticationInfo.principalEmail AS who
FROM `sentinel_audit.cloudaudit_googleapis_com_data_access`
WHERE protopayload_auditlog.methodName = "storage.setIamPermissions"
  AND TO_JSON_STRING(protopayload_auditlog) LIKE "%allUsers%"
ORDER BY timestamp DESC;
