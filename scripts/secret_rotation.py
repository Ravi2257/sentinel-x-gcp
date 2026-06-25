#!/usr/bin/env python3
"""Add a new version to a Secret Manager secret and disable older versions.

Usage:
  python secret_rotation.py --project-id P --secret-id my-secret
Dependencies: google-cloud-secret-manager
"""
import argparse, secrets, string
from google.cloud import secretmanager


def rotate_secret(project_id: str, secret_id: str, new_value: str | None = None) -> str:
    client = secretmanager.SecretManagerServiceClient()
    parent = f"projects/{project_id}/secrets/{secret_id}"

    if new_value is None:
        alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
        new_value = "".join(secrets.choice(alphabet) for _ in range(32))

    response = client.add_secret_version(
        parent=parent, payload={"data": new_value.encode("utf-8")}
    )
    new_ver = response.name

    for ver in client.list_secret_versions(parent=parent):
        if ver.name != new_ver and ver.state.name == "ENABLED":
            client.disable_secret_version(name=ver.name)
            print(f"  Disabled: {ver.name}")

    print(f"Rotated {secret_id} -> new version: {new_ver.split('/')[-1]}")
    return new_ver


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--project-id", required=True)
    ap.add_argument("--secret-id", required=True)
    ap.add_argument("--new-value", default=None, help="Leave blank to auto-generate")
    args = ap.parse_args()
    rotate_secret(args.project_id, args.secret_id, args.new_value)


if __name__ == "__main__":
    main()
