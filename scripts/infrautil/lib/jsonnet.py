"""Jsonnet to YAML conversion module."""

import json
from pathlib import Path
from typing import Any

import _jsonnet
import yaml


def build_yaml(filepath: str | Path) -> str:
    """Convert a Jsonnet file to YAML format.
    
    Args:
        filepath: Path to the Jsonnet file to process
        
    Returns:
        YAML string representation of the Jsonnet content
        
    Raises:
        RuntimeError: If Jsonnet evaluation fails
        ValueError: If JSON parsing fails
    """
    filepath_path = Path(filepath)
    filepath_str = str(filepath_path.resolve())
    
    # Set up import callback to allow imports relative to the file
    import_dirs = [str(filepath_path.parent)]
    
    try:
        json_str = _jsonnet.evaluate_file(filepath_str, jpathdir=import_dirs)
    except Exception as e:
        raise RuntimeError(f"failed to evaluate jsonnet file: {e}") from e
    
    try:
        json_result: Any = json.loads(json_str)
    except json.JSONDecodeError as e:
        raise ValueError(f"failed to parse jsonnet output: {e}") from e
    
    if not isinstance(json_result, list):
        json_result = [json_result]
    
    yaml_parts = []
    for item in json_result:
        yaml_str = yaml.dump(
            item,
            default_flow_style=False,
            sort_keys=False,
            indent=2,
            allow_unicode=True,
        )
        yaml_parts.append(yaml_str)
    
    return "".join(yaml_parts)
