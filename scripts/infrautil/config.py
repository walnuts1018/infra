"""Configuration management for infrautil."""

from pathlib import Path
from typing import Final

DEFAULT_APP_DIR: Final[str] = "k8s/apps"
DEFAULT_NAMESPACE_OUTPUT: Final[str] = "k8s/namespaces/namespaces.json5"
DEFAULT_SNAPSHOT_OUTPUT: Final[str] = "k8s/snapshots/apps"
DEFAULT_HELM_SNAPSHOT_INPUT: Final[str] = "k8s/snapshots/apps"
DEFAULT_HELM_SNAPSHOT_OUTPUT: Final[str] = "k8s/snapshots/helm"


class Config:
    """Global configuration container."""
    
    def __init__(self) -> None:
        self.verbose: bool = False
        self.root_dir: Path = Path.cwd()
