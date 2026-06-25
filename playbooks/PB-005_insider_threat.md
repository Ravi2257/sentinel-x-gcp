# PB-005 - Insider Threat (Secret Exfiltration)

## IDENTIFY
- Detection D6: >10 distinct secrets read by one principal in 1 hour.
- Reads concentrated near an employee's departure date.

## CONTAIN
- Revoke the principal's Secret Manager bindings.
- Rotate ALL accessed secrets (`scripts/secret_rotation.py`).

## ERADICATE
- Confirm Data Access logging is enabled on Secret Manager.
- Add VPC-SC around secretmanager.googleapis.com.

## RECOVER
- Re-issue rotated credentials to legitimate services.
- Review offboarding access-revocation process.

## LESSONS LEARNED
- Least-privilege on secrets + per-secret access logging.
- Alert on bulk-read patterns, not single reads.
