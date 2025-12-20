"""Namespace command implementation."""

import logging
from pathlib import Path

from infrautil.lib.apps import get_app_json
from infrautil.lib.namespace import gen_namespace_json, get_namespaces


logger = logging.getLogger(__name__)


def execute_namespace(app_dir: str, output_file: str) -> int:
    """Generate namespace manifest from application configurations.
    
    Args:
        app_dir: Directory containing application subdirectories with app.json5
        output_file: Path to write namespace JSON5 file
        
    Returns:
        Exit code (0 for success, 1 for failure)
    """
    try:
        app_jsons = get_app_json(app_dir)
        logger.info(f"found {len(app_jsons)} applications")
        
    except Exception as e:
        logger.error(f"failed to get app json: {e}")
        return 1
    
    output_path = Path(output_file)
    
    existing_namespaces = []
    if output_path.exists():
        try:
            with open(output_path, "r", encoding="utf-8") as f:
                existing_namespaces = get_namespaces(f)
        except Exception as e:
            logger.warning(f"failed to read existing namespaces: {e}")
    
    try:
        namespace_json = gen_namespace_json(app_jsons, existing_namespaces)
        
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(namespace_json, encoding="utf-8")
        
        logger.info(f"namespace manifest written to {output_file}")
        return 0
        
    except Exception as e:
        logger.error(f"failed to generate namespace json: {e}")
        return 1
