#!/usr/bin/env python3
"""Disable a compromised GCP service account and write an audit entry.

Usage:
  python incident_response.py --project-id PROJECT --sa-email SA@PROJECT.iam.gserviceaccount.com
Dependencies: google-cloud-iam, google-cloud-logging  (see requirements.txt)
"""
import argparse
from datetime import datetime, timezone
from google.cloud import iam_admin_v1
from google.cloud import logging as gcp_logging


def disable_service_account(project_id: str, sa_email: str, reason: str) -> dict:
    client = iam_admin_v1.IAMClient()
    sa_name = f"projects/-/serviceAccounts/{sa_email}"

    sa = client.get_service_account(name=sa_name)
    if sa.disabled:
        return {"status": "already_disabled", "email": sa_email}

    client.disable_service_account(
        request=iam_admin_v1.DisableServiceAccountRequest(name=sa_name)
    )

    log_client = gcp_logging.Client(project=project_id)
    log_client.logger("sentinel-x-ir").log_struct(
        {
            "event_type": "SERVICE_ACCOUNT_DISABLED",
            "sa_email": sa_email,
            "reason": reason,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "triggered_by": "SENTINEL-X Auto-IR",
        },
        severity="WARNING",
    )
    return {"status": "disabled", "email": sa_email, "reason": reason}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--project-id", required=True)
    ap.add_argument("--sa-email", required=True)
    ap.add_argument("--reason", default="Suspicious activity - SENTINEL-X")
    args = ap.parse_args()
    print(disable_service_account(args.project_id, args.sa_email, args.reason))


if __name__ == "__main__":
    main()
