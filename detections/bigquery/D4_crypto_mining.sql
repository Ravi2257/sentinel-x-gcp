-- Technique: T1496 (Resource Hijacking) | Severity: HIGH
-- TP: >5 VM instances created by one principal within 10 minutes.
-- FP: legitimate autoscaling/batch job (exclude its SA).
SELECT principalEmail, COUNT(*) AS vm_count,
       MIN(timestamp) AS first_seen, MAX(timestamp) AS last_seen
FROM (
  SELECT protopayload_auditlog.authenticationInfo.principalEmail AS principalEmail,
         timestamp
  FROM `sentinel_audit.cloudaudit_googleapis_com_activity`
  WHERE protopayload_auditlog.methodName = "v1.compute.instances.insert"
    AND timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 10 MINUTE)
)
GROUP BY principalEmail
HAVING vm_count > 5;
