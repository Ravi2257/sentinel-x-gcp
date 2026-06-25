-- Technique: T1190 (Exploit Public-Facing Application) | Severity: HIGH
-- TP: firewall rule created/patched allowing 0.0.0.0/0 to SSH(22) or RDP(3389).
-- FP: an approved bastion exposure (rare; should use IAP instead).
SELECT timestamp,
       protopayload_auditlog.authenticationInfo.principalEmail AS who,
       protopayload_auditlog.resourceName AS rule_name
FROM `sentinel_audit.cloudaudit_googleapis_com_activity`
WHERE protopayload_auditlog.methodName IN
      ("v1.compute.firewalls.insert", "v1.compute.firewalls.patch")
  AND TO_JSON_STRING(protopayload_auditlog.request) LIKE "%0.0.0.0/0%"
  AND (
    TO_JSON_STRING(protopayload_auditlog.request) LIKE "%\"22\"%"
    OR TO_JSON_STRING(protopayload_auditlog.request) LIKE "%\"3389\"%"
  )
ORDER BY timestamp DESC;
