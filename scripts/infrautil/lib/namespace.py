"""Namespace management utilities."""

from typing import TYPE_CHECKING, TextIO

import json5

if TYPE_CHECKING:
    from infrautil.lib.apps import AppJSON


def get_namespaces(reader: TextIO) -> list[str]:
    """Extract namespace list from JSON5 file.

    Args:
        reader: Text stream containing JSON5 data

    Returns:
        List of namespace names

    Raises:
        ValueError: If JSON parsing fails
    """
    content = reader.read()

    if not content.strip():
        return []

    try:
        namespaces: list[str] = json5.loads(content)
        return namespaces
    except Exception as e:
        raise ValueError(f"failed to parse namespace json: {e}") from e


def gen_namespace_json(app_jsons: list["AppJSON"], existing_ns: list[str] | None = None) -> str:
    """Generate namespace JSON5 from application configurations.

    Args:
        app_jsons: List of AppJSON objects containing namespace information
        existing_ns: Optional list of existing namespaces to merge

    Returns:
        JSON5 string containing sorted, unique namespace list
    """
    if existing_ns is None:
        existing_ns = []

    namespaces = list(existing_ns)

    for app_json in app_jsons:
        namespaces.append(app_json.namespace)

    unique_namespaces = sorted(set(namespaces))

    # json5.dumps is typed to return str, but mypy needs explicit annotation
    return str(json5.dumps(unique_namespaces, indent=2))
