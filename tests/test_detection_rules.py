#!/usr/bin/env python3
"""Validate that detection rule files carry the metadata CI requires."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_every_sql_has_technique_comment():
    for sql in (ROOT / "detections" / "bigquery").glob("*.sql"):
        text = sql.read_text(encoding="utf-8")
        assert "Technique:" in text, f"{sql.name} missing Technique comment"


def test_every_yaral_has_required_meta():
    required = ["author", "description", "technique", "severity", "false_positives"]
    for rule in (ROOT / "detections" / "yaral").glob("*.yaral"):
        text = rule.read_text(encoding="utf-8")
        for field in required:
            assert field in text, f"{rule.name} missing meta {field}"


def test_mitre_ids_well_formed():
    pat = re.compile(r"T\d{4}(\.\d{3})?")
    for rule in (ROOT / "detections" / "yaral").glob("*.yaral"):
        m = re.search(r'technique\s*=\s*"([^"]+)"', rule.read_text(encoding="utf-8"))
        assert m and pat.fullmatch(m.group(1)), f"{rule.name} bad technique id"
