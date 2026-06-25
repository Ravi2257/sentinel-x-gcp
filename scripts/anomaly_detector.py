#!/usr/bin/env python3
"""Detect anomalous API call volumes using z-score against a baseline window.

Big-O: O(n) per run, n = number of principals. One pass for mean/std, one pass
to flag. pstdev divides by n (population); use stdev (n-1) if counts are a sample.

Usage:
  python anomaly_detector.py --project-id P --window-hours 1 --threshold 3.0
Dependencies: google-cloud-bigquery
"""
import argparse
from statistics import mean, pstdev

QUERY = """
SELECT
  protopayload_auditlog.authenticationInfo.principalEmail AS principal,
  COUNT(*) AS api_calls
FROM `{project}.{dataset}.cloudaudit_googleapis_com_activity`
WHERE timestamp BETWEEN
  TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL {window_hours} HOUR)
  AND CURRENT_TIMESTAMP()
GROUP BY principal
"""


def flag_anomalies(counts: dict[str, float], threshold: float = 3.0) -> list[tuple[str, float]]:
    vals = list(counts.values())
    if len(vals) < 2:
        return []
    mu, sigma = mean(vals), pstdev(vals)
    if sigma == 0:
        return []
    return [
        (who, round((c - mu) / sigma, 2))
        for who, c in counts.items()
        if abs((c - mu) / sigma) > threshold
    ]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--project-id", required=True)
    ap.add_argument("--dataset", default="sentinel_audit")
    ap.add_argument("--window-hours", type=int, default=1)
    ap.add_argument("--threshold", type=float, default=3.0)
    args = ap.parse_args()

    from google.cloud import bigquery  # lazy import: keeps flag_anomalies unit-testable offline

    client = bigquery.Client(project=args.project_id)
    sql = QUERY.format(
        project=args.project_id, dataset=args.dataset, window_hours=args.window_hours
    )
    counts = {row.principal: row.api_calls for row in client.query(sql).result()}

    anomalies = flag_anomalies(counts, args.threshold)
    if not anomalies:
        print("No anomalies detected.")
    for principal, z in sorted(anomalies, key=lambda x: -x[1]):
        print(f"ANOMALY  z={z:+.2f}  calls={counts[principal]}  {principal}")


if __name__ == "__main__":
    main()
