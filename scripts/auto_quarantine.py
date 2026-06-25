#!/usr/bin/env python3
"""Quarantine a VM by applying a deny-all network tag and removing allow tags.

Usage:
  python auto_quarantine.py --project-id P --zone us-central1-a --instance vm
Dependencies: google-cloud-compute
"""
import argparse
from google.cloud import compute_v1

QUARANTINE_TAG = "quarantine-deny-all"
DENY_RULE_NAME = "sentinel-quarantine-deny-all"


def quarantine_vm(project_id: str, zone: str, instance_name: str):
    inst_client = compute_v1.InstancesClient()
    fw_client = compute_v1.FirewallsClient()

    try:
        fw_client.get(project=project_id, firewall=DENY_RULE_NAME)
    except Exception:
        fw_body = compute_v1.Firewall(
            name=DENY_RULE_NAME,
            network=f"projects/{project_id}/global/networks/sentinel-x-vpc",
            priority=500,
            direction="INGRESS",
            denied=[compute_v1.Denied(I_p_protocol="all")],
            source_ranges=["0.0.0.0/0"],
            target_tags=[QUARANTINE_TAG],
        )
        fw_client.insert(project=project_id, firewall_resource=fw_body).result()

    inst = inst_client.get(project=project_id, zone=zone, instance=instance_name)
    new_tags = [QUARANTINE_TAG] + [t for t in inst.tags.items if t != "ssh-open"]
    tags_body = compute_v1.Tags(items=new_tags, fingerprint=inst.tags.fingerprint)
    inst_client.set_tags(
        project=project_id, zone=zone, instance=instance_name, tags_resource=tags_body
    ).result()
    print(f"VM {instance_name} quarantined with tag: {QUARANTINE_TAG}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--project-id", required=True)
    ap.add_argument("--zone", required=True)
    ap.add_argument("--instance", required=True)
    args = ap.parse_args()
    quarantine_vm(args.project_id, args.zone, args.instance)


if __name__ == "__main__":
    main()
