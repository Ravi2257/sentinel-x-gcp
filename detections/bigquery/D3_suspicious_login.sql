-- Technique: T1078 (Valid Accounts) | Severity: HIGH
-- TP: API activity from an IP outside the corp allowlist and private ranges.
-- FP: new legitimate office/VPN egress IP (add to corp_ip_allowlist table).
SELECT timestamp,
       protopayload_auditlog.authenticationInfo.principalEmail AS who,
       protopayload_auditlog.requestMetadata.callerIp AS ip
FROM `sentinel_audit.cloudaudit_googleapis_com_activity`
WHERE protopayload_auditlog.requestMetadata.callerIp NOT IN
      (SELECT ip FROM `sentinel_audit.corp_ip_allowlist`)
  AND protopayload_auditlog.requestMetadata.callerIp NOT LIKE "10.%"
  AND protopayload_auditlog.requestMetadata.callerIp NOT LIKE "172.%"
  AND protopayload_auditlog.requestMetadata.callerIp NOT LIKE "192.168.%"
ORDER BY timestamp DESC;
