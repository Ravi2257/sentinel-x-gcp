# Deployment Status — Implemented vs. Reference Architecture

SENTINEL-X was built and validated hands-on in a **single-project GCP sandbox on a
consumer (Gmail) account**. That account has **no Organization resource**, which is a
hard prerequisite for a specific set of GCP security controls. Those controls are
therefore included as **reference architecture** — fully designed and documented, with
working configuration — but **not deployed** in the sandbox. Everything else was
deployed and exercised end-to-end.

This document is the single source of truth for what is live vs. reference. Other docs
(architecture diagram, data-flow, compliance mapping) describe the **target design** and
should be read against this table.

## ✅ Implemented and validated (project-scoped, no Organization required)

| Capability | Phase | Evidence |
|-----------|-------|----------|
| Audit logs → BigQuery sink (partitioned) | 2 | `screenshots/bq_audit_table.png` |
| IAM least-privilege analysis + default-SA editor removal | 4 | `screenshots/iam_analyzer_output.png` |
| Workload Identity Federation (keyless GitHub CI) | 5 | `terraform/modules/iam`, WIF provider with attribute-condition |
| BigQuery detections D1–D9 (MITRE-mapped) | 7 | `screenshots/bq_detection_query.png` |
| Z-score anomaly detection | 13 | `screenshots/anomaly_detected.png` |
| Binary Authorization (attestor + policy, block unsigned) | 11 | `screenshots/binaryauth_block.png` |
| Container signing (cosign v3 + KMS) & attestation | 11 | KMS `sentinel-kr/sentinel-key` |
| IaC scanning in CI (Checkov + Trivy + Semgrep) | 12 | `screenshots/trivy_scan.png`, `screenshots/checkov_scan.png` |
| Closed-loop auto-remediation (log→Pub/Sub→Cloud Function) | 14 | `screenshots/auto_remediation_log.png` |
| Attack simulations (priv-esc, public bucket, VM burst) | 16 | `screenshots/attack_*.png` |
| Cloud KMS + CMEK | — | `terraform/modules/security` |
| Cloud Armor WAF policy (project-scoped) | — | `terraform/modules/security` |

## 📐 Reference architecture (requires an Organization — designed, not deployed)

These require an Organization resource, so on a consumer Gmail account every attempt
fails identically with a *"Gaia id not found"* / *"you need to be part of an
organization"* error. They are documented as design and would deploy unchanged under an
Org (e.g. Google Workspace / Cloud Identity, or a GCP Organization node).

| Control | Runbook phase | Why it needs an Org | What it enforces |
|---------|---------------|---------------------|------------------|
| **Security Command Center (SCC)** | 3 | SCC is an org-level service; findings and posture roll up to the Organization. Even Standard tier requires an Org. | Centralized CSPM findings, asset inventory, posture. |
| **Organization Policy + IAM Deny** | 6 | Org Policy and IAM Deny policies attach to the Org/folder/project *hierarchy*; `setOrgPolicy` is denied without an Org — even when scoped with `--project`. | Prevent SA key creation, restrict resource locations, hard-deny risky permissions above IAM allow. |
| **VPC Service Controls** | 9 | Service perimeters live inside an **Access Policy**, which only exists under an Organization. | A perimeter around BigQuery/GCS APIs to block data exfiltration even with valid credentials. |
| **IAP context-aware access levels** | 10 | Access Context Manager access levels are stored in the org Access Policy (same dependency as VPC-SC). | Condition IAP access on corp IP range / device posture. *Base IAP lockdown (private ingress + `run.invoker`) WAS deployed in Phase 10; only the context-aware layer is reference-only.* |
| **Chronicle SIEM (YARA-L)** | 8 | Chronicle is a contract/licensed product, not enabled on a free project. | Real-time UDM normalization + YARA-L rule matching. YARA-L rules are provided in `detections/yaral/` as portable detection-as-code. |
| **Cloud IDS** | — | Not free-tier; deliberately not deployed to keep the sandbox at ~$0. | Network-layer intrusion detection (Palo Alto engine). |

## Why this distinction matters (and is a strength)

Knowing *which* controls depend on the Organization hierarchy — and hitting that wall
in practice — is exactly the operational knowledge these controls demand. The
detection, response, identity, and supply-chain layers that make up the core of a
cloud blue-team platform were all deployed and exercised for real; the org-gated
preventive guardrails are documented at design fidelity and drop in unchanged once an
Organization exists.
