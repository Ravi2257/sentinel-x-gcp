# SENTINEL-X Data Flow

> This describes the **target design**. Chronicle SIEM and Security Command Center
> (steps 5, 7) are org-gated reference components — see
> [`deployment-status.md`](deployment-status.md). The deployed path is
> Audit Log → Log Router → BigQuery (detections) and → Pub/Sub → Cloud Function
> (auto-remediation).

1. A user or workload triggers a GCP API call (e.g. `SetIamPolicy`,
   `storage.buckets.setIamPolicy`).
2. Cloud Audit Logs captures the event (WHO, WHAT, WHEN, WHERE).
3. Log Router evaluates the event against sink filters and routes it to
   **BigQuery** (for SQL detections) and **Pub/Sub** (for SIEM + SOAR) at once.
4. BigQuery receives the log for scheduled SQL detection queries.
5. Pub/Sub delivers the event to Chronicle SIEM (UDM normalization + YARA-L)
   and to the auto-remediation Cloud Functions.
6. A detection fires (SQL query returns rows OR YARA-L rule matches).
7. Security Command Center aggregates the finding.
8. Eventarc / Pub/Sub invokes the appropriate Cloud Function.
9. The Cloud Function executes the remediation (disable SA, revoke public
   access, delete open firewall rule, etc.).
10. All remediation actions are logged back to Cloud Logging / BigQuery for the
    audit trail and ML feedback loop.

```
Action -> Audit Log -> Log Router --+--> BigQuery (SQL detections)
                                    |
                                    +--> Pub/Sub --> Chronicle (YARA-L)
                                              |
                                              +--> Cloud Function (auto-remediate)
                                                        |
                                                        +--> log REMEDIATED
```
