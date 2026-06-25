# Attack Simulations

> SAFETY: Run these ONLY in a throwaway sandbox project. Each script triggers a
> detection and then cleans up after itself. NEVER run against a shared, work,
> or production project.

| Script | Triggers | Detection |
|--------|----------|-----------|
| SIM-001_privilege_escalation.sh | Owner role grant (on a disposable SA) | D1 / YARAL-1 |
| SIM-002_public_bucket.sh | allUsers on a bucket | D2 + auto-remediation |
| SIM-003_crypto_mining.sh | VM creation burst | D4 / YARAL-3 |

> SIM-001 grants/revokes `roles/owner` on a **throwaway service account**, never your own
> account — revoking owner from yourself on a project you own can lock you out.

## Usage
```bash
bash attack-simulations/SIM-001_privilege_escalation.sh $PROJECT_ID
```
After each sim, run the matching detection query to confirm it fires, then
screenshot the terminal + result side by side.
