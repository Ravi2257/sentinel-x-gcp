#!/usr/bin/env bash
# SIM-001 — Privilege Escalation (triggers detection D1)
# SAFETY: sandbox project ONLY. Never run against shared/work/prod.
#
# Grants then revokes roles/owner on a THROWAWAY service account — NOT your own
# account. If you are already project owner, revoking owner from your own user
# would remove your legitimate access and can lock you out; using a disposable
# SA avoids that while still producing the SetIamPolicy(ADD owner) event D1 detects.
set -euo pipefail
PROJECT_ID="${1:?Usage: SIM-001_privilege_escalation.sh PROJECT_ID}"
SIM_SA="sim001-privesc@${PROJECT_ID}.iam.gserviceaccount.com"

echo "[SIM-001] Creating throwaway principal..."
gcloud iam service-accounts create sim001-privesc \
  --display-name="SIM-001 priv-esc target" --project="$PROJECT_ID" >/dev/null 2>&1 || true
sleep 10   # let the new SA propagate before binding

echo "[SIM-001] Granting roles/owner to $SIM_SA (simulated privilege escalation)..."
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SIM_SA" --role="roles/owner" >/dev/null

echo "[SIM-001] Detection D1 should fire within ~2 min. Reverting in 30s..."
sleep 30
gcloud projects remove-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SIM_SA" --role="roles/owner" >/dev/null

echo "[SIM-001] Deleting throwaway principal..."
gcloud iam service-accounts delete "$SIM_SA" -q >/dev/null 2>&1 || true
echo "[SIM-001] Cleaned up."
