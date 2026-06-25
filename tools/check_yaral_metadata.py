#!/usr/bin/env python3
"""Fail CI if any YARA-L rule is missing required meta fields."""
import sys, re
from pathlib import Path

REQUIRED = ["author", "description", "technique", "severity", "false_positives"]
TECH_RE = re.compile(r"T\d{4}(\.\d{3})?")


def check(path: Path) -> list[str]:
    text = path.read_text(encoding="utf-8")
    errors = [f"missing meta: {field}" for field in REQUIRED if field not in text]
    m = re.search(r'technique\s*=\s*"([^"]+)"', text)
    if m and not TECH_RE.fullmatch(m.group(1)):
        errors.append(f"bad MITRE id: {m.group(1)}")
    return errors


def main(rules_dir: str):
    failed = False
    for f in sorted(Path(rules_dir).glob("*.yaral")):
        errs = check(f)
        if errs:
            failed = True
            print(f"FAIL {f.name}:")
            for e in errs:
                print(f"   - {e}")
        else:
            print(f"PASS {f.name}")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "detections/yaral")
