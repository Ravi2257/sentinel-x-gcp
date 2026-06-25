-- Technique: T1610 (Deploy Container) | Severity: HIGH
-- TP: Binary Authorization rejected an unsigned/unattested image at admission.
-- FP: none expected; investigate every hit.
SELECT timestamp,
       resource.labels.service_name AS service,
       protopayload_auditlog.status.message AS violation,
       protopayload_auditlog.authenticationInfo.principalEmail AS who
FROM `sentinel_audit.cloudaudit_googleapis_com_activity`
WHERE protopayload_auditlog.serviceName = "binaryauthorization.googleapis.com"
  AND protopayload_auditlog.status.code != 0
ORDER BY timestamp DESC;
