-- Technique: T1136.003 (Create Account: Cloud Account) | Severity: CRITICAL
-- TP: a SA is created AND a user-managed key exported by the same actor <=5 min.
-- FP: rare legitimate onboarding automation (should use WIF instead of keys).
WITH sa_create AS (
  SELECT protopayload_auditlog.authenticationInfo.principalEmail AS actor,
         timestamp AS t_create
  FROM `sentinel_audit.cloudaudit_googleapis_com_activity`
  WHERE protopayload_auditlog.methodName = "google.iam.admin.v1.CreateServiceAccount"
),
key_create AS (
  SELECT protopayload_auditlog.authenticationInfo.principalEmail AS actor,
         timestamp AS t_key
  FROM `sentinel_audit.cloudaudit_googleapis_com_activity`
  WHERE protopayload_auditlog.methodName LIKE "%CreateServiceAccountKey%"
)
SELECT s.actor, s.t_create, k.t_key
FROM sa_create s
JOIN key_create k ON s.actor = k.actor
WHERE TIMESTAMP_DIFF(k.t_key, s.t_create, MINUTE) BETWEEN 0 AND 5;
