"""Tests for jsonnet module."""

from pathlib import Path

import pytest
import yaml

from infrautil.lib.jsonnet import build_yaml


TESTFILES_DIR = Path(__file__).parent.parent / "lib" / "testfiles"


def load_yaml_file(filename: str) -> str:
    """Load YAML content from test file."""
    filepath = TESTFILES_DIR / filename
    return filepath.read_text(encoding="utf-8")


def normalize_yaml(yaml_str: str) -> dict:
    """Parse and normalize YAML for comparison."""
    return yaml.safe_load(yaml_str)


@pytest.mark.parametrize(
    "jsonnet_file,expected_yaml_file",
    [
        ("deployment.jsonnet", "deployment.yaml"),
        ("ingress.jsonnet", "ingress.yaml"),
        ("pvc.jsonnet", "pvc.yaml"),
        ("service.jsonnet", "service.yaml"),
    ],
)
def test_build_yaml(jsonnet_file: str, expected_yaml_file: str) -> None:
    """Test Jsonnet to YAML conversion."""
    jsonnet_path = TESTFILES_DIR / jsonnet_file
    expected_yaml = load_yaml_file(expected_yaml_file)
    
    result = build_yaml(jsonnet_path)
    
    result_parsed = normalize_yaml(result)
    expected_parsed = normalize_yaml(expected_yaml)
    
    assert result_parsed == expected_parsed


def test_build_yaml_nonexistent_file() -> None:
    """Test that nonexistent files raise RuntimeError."""
    with pytest.raises(RuntimeError):
        build_yaml("/nonexistent/file.jsonnet")
