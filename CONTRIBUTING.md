# Contributing to SENTINEL-X

## Adding a detection rule

Every detection rule (BigQuery SQL, YARA-L, or Sigma) MUST include:

1. **A technique tag** - a MITRE ATT&CK ID in the form `T####` or `T####.###`.
2. **A true-positive definition** - one sentence describing what malicious
   activity the rule fires on.
3. **A false-positive register** - what legitimate activity looks similar and
   how it is excluded.
4. **A severity** - CRITICAL / HIGH / MEDIUM / LOW.

### BigQuery SQL rules
- File goes in `detections/bigquery/` named `D<n>_<short_name>.sql`.
- The first comment line must contain `Technique: T####`.
- CI (`tools/`) greps for the technique comment and fails the build if missing.

### YARA-L rules
- File goes in `detections/yaral/` with a `.yaral` extension.
- The `meta:` block must contain author, description, technique, severity,
  and false_positives. `tools/check_yaral_metadata.py` enforces this.

### Sigma rules
- File goes in `detections/sigma/` with a `.yml` extension.
- Must pass `tools/validate_detections.py` (checks required fields + MITRE tags).

## Workflow
1. Branch from `main`.
2. Add the rule + a fixture in `tests/fixtures/` (known-bad and known-good).
3. Run the validators locally before opening a PR.
4. CI runs all validators automatically on the PR.
