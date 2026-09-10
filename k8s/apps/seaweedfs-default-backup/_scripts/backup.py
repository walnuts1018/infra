#!/usr/bin/env python3
"""Mirrors every seaweedfs-default bucket (minus those tagged skip-backup) to
the seaweedfs-biscuit relay, then on to B2 for offsite retention."""

import json
import subprocess
import sys
from datetime import datetime

RCLONE_CONFIG = "/config/rclone.conf"
SOURCE_REMOTE = "seaweedfs-default"
RELAY_REMOTE = "seaweedfs-biscuit"
RELAY_BUCKET = "seaweedfs-default-backup"
OFFSITE_REMOTE = "b2"
OFFSITE_BUCKET = "walnuts-seaweedfs-biscuit-backup-81f18e5"


def log(level: str, msg: str, **fields: str) -> None:
    entry = {"level": level, "time": datetime.now().astimezone().strftime("%Y-%m-%dT%H:%M:%S%z"), "msg": msg}
    entry.update(fields)
    print(json.dumps(entry), flush=True)


def list_source_buckets() -> list[str]:
    result = subprocess.run(
        ["rclone", "lsf", f"{SOURCE_REMOTE}:", "--dirs-only", f"--config={RCLONE_CONFIG}"],
        capture_output=True,
        text=True,
        check=True,
    )
    return [line.rstrip("/") for line in result.stdout.splitlines() if line.strip()]


def should_skip_backup(tag_set: list[dict[str, str]]) -> bool:
    return any(tag.get("Key") == "skip-backup" for tag in tag_set)


def is_backup_target(bucket: str) -> bool:
    result = subprocess.run(
        ["aws", "s3api", "get-bucket-tagging", "--profile", SOURCE_REMOTE, "--bucket", bucket],
        capture_output=True,
        text=True,
    )
    if result.returncode == 0:
        tag_set: list[dict[str, str]] = json.loads(result.stdout).get("TagSet", [])
        if should_skip_backup(tag_set):
            log("info", "Excluding bucket due to skip-backup tag", bucket=bucket)
            return False
        log("info", "Including bucket in sync", bucket=bucket)
        return True
    if "NoSuchTagSet" in result.stderr or "NoSuchTag" in result.stderr:
        log("info", "Including bucket without tags", bucket=bucket)
        return True
    log("error", "Failed to read bucket tags", bucket=bucket, error=result.stderr)
    sys.exit(1)


def rclone_sync(source: str, dest: str) -> None:
    result = subprocess.run(
        ["rclone", "sync", "--metrics-addr=:9250", f"--config={RCLONE_CONFIG}", "-v", source, dest],
    )
    if result.returncode != 0:
        log("error", "Sync failed", source=source, dest=dest)
        log("error", "Backup process completed with errors")
        sys.exit(1)


def main() -> None:
    log("info", "Starting backup process")

    buckets = list_source_buckets()
    backup_buckets = [bucket for bucket in buckets if is_backup_target(bucket)]

    for bucket in backup_buckets:
        source_path = f"{SOURCE_REMOTE}:{bucket}/"
        dest_path = f"{RELAY_REMOTE}:{RELAY_BUCKET}/{bucket}/"
        log("info", "Sync started", source=source_path, dest=dest_path, bucket=bucket)
        rclone_sync(source_path, dest_path)
        log("info", "Sync completed successfully", source=source_path, dest=dest_path, bucket=bucket)

    for bucket in backup_buckets:
        source_path = f"{RELAY_REMOTE}:{RELAY_BUCKET}/{bucket}/"
        b2_path = f"{OFFSITE_REMOTE}:{OFFSITE_BUCKET}/{bucket}/"
        log("info", "Offsite backup started", source=source_path, dest=b2_path, bucket=bucket)
        rclone_sync(source_path, b2_path)
        log("info", "Offsite backup completed", source=source_path, dest=b2_path, bucket=bucket)

    log("info", "Backup process completed successfully")


if __name__ == "__main__":
    main()
