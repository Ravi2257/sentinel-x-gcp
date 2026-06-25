#!/usr/bin/env python3
"""Fail CI if any Sigma detection rule is missing required metadata fields."""
import sys, re
from pathlib import Path
import yaml

REQUIRED = {"title", "id", "status", "description", "author", "tags", "level"}
TECH_RE = re.compile(r"attack\.t\d{4}(\.\d{3})?$")


def validate(path: Path) -> list[str]:
    errors = []
    with open(path, encoding="utf-8") as f:
        rule = yaml.safe_load(f)
    missing = REQUIRED - set(rule.keys())
    if missing:
        errors.append(f"missing fields: {sorted(missing)}")
    for tag in rule.get("tags", []):
        if tag.startswith("attack.t") and not TECH_RE.match(tag):
            errors.append(f"bad MITRE tag: {tag}")
    return errors


def main(sigma_dir: str):
    failed = False
    for rule_file in sorted(Path(sigma_dir).glob("**/*.yml")):
        errors = validate(rule_file)
        if errors:
            print(f"FAIL: {rule_file}")
            for e in errors:
                print(f"   - {e}")
            failed = True
        else:
            print(f"PASS: {rule_file.name}")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "detections/sigma")
