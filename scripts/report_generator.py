#!/usr/bin/env python3
"""Generate a weekly security posture report from audit metrics (+ optional SCC).

Usage:
  python report_generator.py --project-id P [--org-id ORG_ID]
Dependencies: google-cloud-bigquery, google-cloud-securitycenter
"""
import argparse
from datetime import datetime, timezone
from google.cloud import bigquery

try:
    from google.cloud import securitycenter_v1
    HAS_SCC = True
except ImportError:
    HAS_SCC = False


def get_audit_metrics(project_id: str) -> dict:
    client = bigquery.Client(project=project_id)
    sql = """
    SELECT
      COUNTIF(protopayload_auditlog.methodName="SetIamPolicy") AS iam_changes,
      COUNTIF(protopayload_auditlog.methodName LIKE "%CreateServiceAccountKey%") AS key_creations,
      COUNTIF(protopayload_auditlog.status.code != 0) AS failed_api_calls
    FROM `sentinel_audit.cloudaudit_googleapis_com_activity`
    WHERE timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
    """
    row = list(client.query(sql).result())[0]
    return dict(row.items())


def get_scc_findings_count(org_id: str) -> dict:
    client = securitycenter_v1.SecurityCenterClient()
    parent = f"organizations/{org_id}/sources/-"
    counts = {"CRITICAL": 0, "HIGH": 0, "MEDIUM": 0, "LOW": 0}
    for res in client.list_findings(request={"parent": parent, "filter": 'state="ACTIVE"'}):
        sev = res.finding.severity.name
        if sev in counts:
            counts[sev] += 1
    return counts


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--project-id", required=True)
    ap.add_argument("--org-id", default="")
    args = ap.parse_args()

    now = datetime.now(timezone.utc)
    print("\n=== SENTINEL-X Weekly Security Report ===")
    print(f"Generated: {now.isoformat()}")
    print(f"Project:   {args.project_id}\n")

    print("--- Audit Metrics (7 days) ---")
    for k, v in get_audit_metrics(args.project_id).items():
        print(f"  {k}: {v}")

    if args.org_id and HAS_SCC:
        print("\n--- SCC Active Findings ---")
        for sev, cnt in get_scc_findings_count(args.org_id).items():
            print(f"  {sev}: {cnt}")


if __name__ == "__main__":
    main()
