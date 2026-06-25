#!/usr/bin/env python3
"""Unit tests for the z-score anomaly detector. Run: pytest tests/"""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "scripts"))
from anomaly_detector import flag_anomalies


def test_flags_obvious_outlier():
    # Realistic population: ~20 normal principals plus one attacker.
    # NOTE: a z-score needs enough normal samples that a single outlier does not
    # inflate the std and mask itself. With only 2-3 points it cannot fire -
    # that is a property of the statistic, not a bug.
    counts = {f"normal{i}": 10 + (i % 5) for i in range(20)}
    counts["attacker"] = 5000
    result = dict(flag_anomalies(counts, threshold=3.0))
    assert "attacker" in result
    assert "normal0" not in result


def test_no_anomaly_when_uniform():
    counts = {"a": 100, "b": 100, "c": 100}
    assert flag_anomalies(counts, threshold=3.0) == []


def test_empty_and_single():
    assert flag_anomalies({}, 3.0) == []
    assert flag_anomalies({"only": 42}, 3.0) == []


def test_zero_variance_is_safe():
    counts = {"a": 5, "b": 5, "c": 5, "d": 5}
    assert flag_anomalies(counts, threshold=3.0) == []
