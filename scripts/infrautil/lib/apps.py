"""Application JSON configuration management."""

import json
from pathlib import Path
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class AppJSON(BaseModel):
    """Application configuration model."""
    
    model_config = ConfigDict(populate_by_name=True)
    
    name: str = Field(..., description="Application name")
    namespace: str = Field(..., description="Kubernetes namespace", alias="namespace")


APP_JSON_FILE = "app.json5"


def get_app_json(basedir: str | Path) -> list[AppJSON]:
    """Extract application configurations from directory structure.
    
    Args:
        basedir: Base directory containing application subdirectories
        
    Returns:
        List of AppJSON configuration objects
        
    Raises:
        ValueError: If app.json5 parsing fails
    """
    basedir_path = Path(basedir)
    app_jsons: list[AppJSON] = []
    
    if not basedir_path.exists() or not basedir_path.is_dir():
        return app_jsons
    
    for app_dir in basedir_path.iterdir():
        if not app_dir.is_dir():
            continue
        
        app_json_path = app_dir / APP_JSON_FILE
        if not app_json_path.exists():
            continue
        
        try:
            with open(app_json_path, "r", encoding="utf-8") as f:
                content = f.read()
                data: Any = json.loads(content)
                app_json = AppJSON.model_validate(data)
                app_jsons.append(app_json)
        except (json.JSONDecodeError, ValueError) as e:
            raise ValueError(
                f"failed to decode app json5 {app_dir.name}: {e}"
            ) from e
    
    return app_jsons
