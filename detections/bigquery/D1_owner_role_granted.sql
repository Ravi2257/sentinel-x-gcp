-- Technique: T1548 (Abuse Elevation Control Mechanism) | Severity: CRITICAL
-- TP: a principal was granted roles/owner or roles/editor on the project.
-- FP: approved break-glass automation SA (exclude by principalEmail).
-- Parse the IAM bindingDeltas array with UNNEST rather than string-matching the
-- serialized proto: precise typed comparison, and action="ADD" excludes the
-- REMOVE events (revocations) that a blob LIKE would false-positive on.
SELECT a.timestamp,
       a.protopayload_auditlog.authenticationInfo.principalEmail AS who,
       bd.role,
       a.protopayload_auditlog.resourceName AS resource
FROM `sentinel_audit.cloudaudit_googleapis_com_activity` AS a,
     UNNEST(a.protopayload_auditlog.servicedata_v1_iam.policyDelta.bindingDeltas) AS bd
WHERE a.protopayload_auditlog.methodName = "SetIamPolicy"
  AND bd.role IN ("roles/owner", "roles/editor")
  AND bd.action = "ADD"
ORDER BY a.timestamp DESC;
