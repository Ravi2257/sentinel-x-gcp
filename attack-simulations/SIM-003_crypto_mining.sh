#!/usr/bin/env bash
# SAFETY: sandbox only. Creates 6 e2-micro VMs (free-tier sized, NOT real miners)
# to trip the burst detection, then deletes them to avoid cost.
set -euo pipefail
PROJECT_ID="${1:?Usage: SIM-003_crypto_mining.sh PROJECT_ID}"

echo "[SIM-003] Creating 6 micro VMs to trigger burst detection D4..."
# --no-service-account/--no-scopes: don't attach the (hardened) default compute SA,
# avoiding any actAs dependency; the sim VMs do nothing, so no identity is needed.
for i in $(seq 1 6); do
  gcloud compute instances create "sim-miner-$i" \
    --project="$PROJECT_ID" --zone=us-central1-a --machine-type=e2-micro \
    --no-address --no-service-account --no-scopes >/dev/null &
done
wait

echo "[SIM-003] Deleting test VMs to avoid charges..."
for i in $(seq 1 6); do
  gcloud compute instances delete "sim-miner-$i" \
    --project="$PROJECT_ID" --zone=us-central1-a -q >/dev/null &
done
wait
echo "[SIM-003] All test VMs deleted."
