# PB-006 - Crypto Miner Detection

## IDENTIFY
- Detection D4: >5 VMs created by one principal in 10 min.
- Budget alert spikes; high-CPU machine types appear.

## CONTAIN
- Stop/delete instances created by the principal.
- Disable the compromised account/SA.
- Block the source IP at Cloud Armor.

## ERADICATE
- Audit images/startup scripts used by the miner VMs.
- Add Org Policy quota / machine-type restrictions.

## RECOVER
- Confirm no persistence (startup scripts, cron, SAs).
- Reset affected quotas.

## LESSONS LEARNED
- Budget alert is the fastest tripwire for resource hijacking.
- Restrict machine types and regions via Org Policy.
