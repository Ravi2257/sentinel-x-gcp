# Cost Analysis (Free-Tier First)

| Service | Free Tier | Lab Usage | Est. Cost |
|---------|-----------|-----------|-----------|
| Cloud Logging | 50 GB/month | Audit logs only | $0 |
| BigQuery storage | 10 GB/month | < 1 GB | $0 |
| BigQuery queries | 1 TB/month | < 1 GB | $0 |
| Cloud Functions | 2M invocations/month | Alert-triggered only | $0 |
| Pub/Sub | 10 GB/month | Tiny | $0 |
| Cloud Storage | 5 GB/month | State + small objects | $0 |
| Cloud Run | 2M requests/month | Test services | $0 |
| Cloud Armor | 1M requests/month | Test traffic | $0 |
| KMS | $0.06/key/month | 1 key | $0.06 |
| SCC Standard | FREE (needs Org) | Reference only — no Org on Gmail | skip |
| Cloud IDS | NOT free | SKIP (document only) | skip |
| SCC Premium | PAID | SKIP | skip |
| Chronicle | Contract only | YARA-L files only | skip |

> Org-gated controls (SCC, VPC-SC, Org Policy/IAM Deny) are reference architecture on a
> consumer account — see [`deployment-status.md`](deployment-status.md). They cost $0 here
> because they are not deployed.

**Total: ~$0.06 - $1.00 / month** if you follow the guardrails.

## Guardrails
1. Set a $5 budget alert before creating anything.
2. SCC, VPC-SC, Org Policy/IAM Deny need an Organization — demonstrate in files/docs, do not deploy on a consumer account.
3. Skip Cloud IDS and Chronicle - demonstrate in files/docs, do not deploy.
4. Use `us-central1` for everything.
5. Enable BigQuery partitioned tables, 90-day expiration.
6. `gcloud projects delete $PROJECT_ID` when finished.
