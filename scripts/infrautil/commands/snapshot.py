"""Snapshot command implementation."""

import logging
import shutil
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from infrautil.lib.jsonnet import build_yaml

logger = logging.getLogger(__name__)


def execute_snapshot(app_dir: str, output_dir: str) -> int:
    """Generate YAML snapshots from Jsonnet manifests.

    Args:
        app_dir: Directory containing Jsonnet application manifests
        output_dir: Directory to write YAML output files

    Returns:
        Exit code (0 for success, 1 for failure)
    """
    app_path = Path(app_dir)
    output_path = Path(output_dir)

    if output_path.exists():
        shutil.rmtree(output_path)

    jsonnet_files = list(app_path.rglob("*.jsonnet"))

    if not jsonnet_files:
        logger.warning(f"no jsonnet files found in {app_dir}")
        return 0

    logger.info(f"processing {len(jsonnet_files)} jsonnet files")

    errors = []

    def process_file(jsonnet_file: Path) -> None:
        try:
            yaml_content = build_yaml(jsonnet_file)

            relative_path = jsonnet_file.relative_to(app_path)
            output_file = output_path / relative_path.with_suffix(".yaml")

            output_file.parent.mkdir(parents=True, exist_ok=True)

            output_file.write_text(yaml_content, encoding="utf-8")
            logger.debug(f"processed {jsonnet_file}")

        except Exception as e:
            error_msg = f"failed to process {jsonnet_file}: {e}"
            logger.error(error_msg)
            errors.append(error_msg)

    with ThreadPoolExecutor() as executor:
        futures = [executor.submit(process_file, f) for f in jsonnet_files]

        for future in as_completed(futures):
            future.result()

    if errors:
        logger.error(f"completed with {len(errors)} errors")
        return 1

    logger.info(f"snapshot complete: {len(jsonnet_files)} files processed")
    return 0
