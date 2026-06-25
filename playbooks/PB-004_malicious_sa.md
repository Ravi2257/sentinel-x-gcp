# PB-004 - Malicious / Backdoor Service Account

## IDENTIFY
- Detection D5: SA created + key exported by same actor within 5 min.
- New SA with Editor/Owner that no ticket explains.

## CONTAIN
- Disable the backdoor SA (`scripts/incident_response.py`).
- Revoke all its keys.
- Add IAM Deny for the SA.

## ERADICATE
- Audit all SAs created in the past 30 days.
- Remove bindings the attacker created.
- Enable iam.disableServiceAccountKeyCreation.

## RECOVER
- Recreate only the legitimate automation with WIF.
- Document the timeline.

## LESSONS LEARNED
- Detection D5 + auto-disable closes this fast.
- Org policy prevents key creation entirely.
