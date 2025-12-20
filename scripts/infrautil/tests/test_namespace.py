"""Tests for namespace module."""

import json5
from io import StringIO

import pytest

from infrautil.lib.apps import AppJSON
from infrautil.lib.namespace import gen_namespace_json, get_namespaces


def test_get_namespaces_empty() -> None:
    """Test reading from empty file."""
    reader = StringIO("")
    result = get_namespaces(reader)
    assert result == []


def test_get_namespaces_valid() -> None:
    """Test reading valid namespace list."""
    reader = StringIO('["ns1", "ns2", "ns3"]')
    result = get_namespaces(reader)
    assert result == ["ns1", "ns2", "ns3"]


def test_get_namespaces_invalid_json() -> None:
    """Test reading invalid JSON raises ValueError."""
    reader = StringIO("not valid json")
    with pytest.raises(ValueError):
        get_namespaces(reader)


def test_gen_namespace_json_basic() -> None:
    """Test generating namespace JSON from apps."""
    apps = [
        AppJSON(name="app1", namespace="ns1"),
        AppJSON(name="app2", namespace="ns2"),
    ]
    result = gen_namespace_json(apps)
    parsed = json5.loads(result)
    assert parsed == ["ns1", "ns2"]


def test_gen_namespace_json_duplicates() -> None:
    """Test deduplication of namespaces."""
    apps = [
        AppJSON(name="app1", namespace="ns1"),
        AppJSON(name="app2", namespace="ns1"),
    ]
    result = gen_namespace_json(apps)
    parsed = json5.loads(result)
    assert parsed == ["ns1"]


def test_gen_namespace_json_sorting() -> None:
    """Test namespace list is sorted."""
    apps = [
        AppJSON(name="app1", namespace="ns2"),
        AppJSON(name="app2", namespace="ns1"),
    ]
    result = gen_namespace_json(apps)
    parsed = json5.loads(result)
    assert parsed == ["ns1", "ns2"]


def test_gen_namespace_json_with_existing() -> None:
    """Test merging with existing namespaces."""
    apps = [
        AppJSON(name="app1", namespace="ns1"),
        AppJSON(name="app2", namespace="ns2"),
    ]
    existing = ["ns3"]
    result = gen_namespace_json(apps, existing)
    parsed = json5.loads(result)
    assert parsed == ["ns1", "ns2", "ns3"]
