# PB-001 - Credential Compromise (Stolen Service Account Key)

## IDENTIFY
- SCC finding SERVICE_ACCOUNT_KEY_CREATED or anomaly alert fires.
- Review cloudaudit logs: who created the key, from what IP, when.
- Check key usage from unusual IP / location.
- Run `scripts/ioc_extractor.py` to enumerate actions taken with the key.

## CONTAIN
- `python scripts/incident_response.py --sa-email <SA>` to disable the SA.
- `python scripts/secret_rotation.py` for any secrets the SA could read.
- Add an IAM Deny policy blocking the SA from further actions.
- `python scripts/snapshot_vm.py` for any VMs the SA touched.

## ERADICATE
- Delete all user-managed keys for the SA.
- Audit all resources created/modified by the SA in the past 30 days.
- Remove any IAM bindings the attacker created.
- Enable Org Policy iam.disableServiceAccountKeyCreation.

## RECOVER
- Create a new least-privilege SA.
- Migrate the workload to Workload Identity Federation (no keys).
- Update applications that used the old SA.
- Run `scripts/report_generator.py` to document the incident.

## LESSONS LEARNED
- WIF for all CI/CD eliminates SA keys.
- Budget alert catches unauthorized compute spend.
- VPC-SC restricts key usage by origin network.
