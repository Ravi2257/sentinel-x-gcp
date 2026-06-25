#!/usr/bin/env python3
"""Create a forensic snapshot of every disk on a (possibly compromised) VM.

Usage:
  python snapshot_vm.py --project-id P --zone us-central1-a --instance-name vm
Dependencies: google-cloud-compute
"""
import argparse
from datetime import datetime, timezone
from google.cloud import compute_v1


def snapshot_vm_disk(project_id: str, zone: str, instance_name: str) -> list[str]:
    inst_client = compute_v1.InstancesClient()
    disks_client = compute_v1.DisksClient()

    instance = inst_client.get(project=project_id, zone=zone, instance=instance_name)
    ts = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    created = []

    for disk in instance.disks:
        disk_name = disk.source.split("/")[-1]
        snap_name = f"forensic-{instance_name}-{disk_name}-{ts}"[:63]
        snap_body = compute_v1.Snapshot(
            name=snap_name,
            source_disk=disk.source,
            labels={"purpose": "forensic", "incident": "sentinel-x", "ts": ts},
        )
        op = disks_client.create_snapshot(
            project=project_id, zone=zone, disk=disk_name, snapshot_resource=snap_body
        )
        op.result()
        created.append(snap_name)
        print(f"  Snapshot created: {snap_name}")
    return created


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--project-id", required=True)
    ap.add_argument("--zone", required=True)
    ap.add_argument("--instance-name", required=True)
    args = ap.parse_args()
    snaps = snapshot_vm_disk(args.project_id, args.zone, args.instance_name)
    print(f"Forensic snapshots: {snaps}")


if __name__ == "__main__":
    main()
