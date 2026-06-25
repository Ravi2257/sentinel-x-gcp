#!/usr/bin/env python3
"""Extract IOCs (IPs, SA emails) from BigQuery audit logs and write a report.

Usage:
  python ioc_extractor.py --project-id P --hours 1 --output iocs.json
Dependencies: google-cloud-bigquery
"""
import json, re, argparse
from datetime import datetime, timezone
from google.cloud import bigquery

IP_RE = re.compile(r"\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b")
SA_RE = re.compile(r"[a-z0-9\-]+@[a-z0-9\-]+\.iam\.gserviceaccount\.com")


def extract_iocs(project_id: str, hours: int = 1) -> dict:
    client = bigquery.Client(project=project_id)
    sql = f"""
    SELECT TO_JSON_STRING(protopayload_auditlog) AS payload
    FROM `{project_id}.sentinel_audit.cloudaudit_googleapis_com_activity`
    WHERE timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL {hours} HOUR)
      AND protopayload_auditlog.status.code IS NOT NULL
    LIMIT 5000
    """
    ips, sas = set(), set()
    for row in client.query(sql).result():
        payload = row.payload or ""
        ips.update(IP_RE.findall(payload))
        sas.update(SA_RE.findall(payload))

    return {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "window_hours": hours,
        "suspicious_ips": sorted(ips),
        "service_accounts": sorted(sas),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--project-id", required=True)
    ap.add_argument("--hours", type=int, default=1)
    ap.add_argument("--output", default="iocs.json")
    args = ap.parse_args()
    report = extract_iocs(args.project_id, args.hours)
    with open(args.output, "w") as f:
        json.dump(report, f, indent=2)
    print(
        f"IOC report: {args.output} "
        f"({len(report['suspicious_ips'])} IPs, {len(report['service_accounts'])} SAs)"
    )


if __name__ == "__main__":
    main()
