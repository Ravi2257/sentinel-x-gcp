#!/usr/bin/env bash
# SAFETY: sandbox project only. Makes a bucket public to trigger D2 + remediation.
set -euo pipefail
PROJECT_ID="${1:?Usage: SIM-002_public_bucket.sh PROJECT_ID}"
BUCKET="gs://sentinel-sim002-${PROJECT_ID}"

gsutil mb -l us-central1 "$BUCKET"
echo "[SIM-002] Making bucket public (triggers D2 + auto-remediation)..."
gsutil iam ch allUsers:objectViewer "$BUCKET"

echo "[SIM-002] Watch the Cloud Function revert it. Cleaning up in 90s..."
sleep 90
gsutil rb "$BUCKET" 2>/dev/null || true
echo "[SIM-002] Done."
