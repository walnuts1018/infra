#!/usr/bin/env -S deno run --allow-run --allow-env --allow-read
/**
 * Mirrors every seaweedfs-default bucket (minus those tagged skip-backup) to
 * the seaweedfs-biscuit relay, then on to B2 for offsite retention.
 *
 * Auth for the seaweedfs-default source is handled entirely by rclone's own
 * env_auth (AWS SDK default credential chain reading AWS_WEB_IDENTITY_TOKEN_FILE
 * / AWS_ROLE_ARN / AWS_ENDPOINT_URL_STS) and, for the bucket-tagging check
 * below, by aws-cli reading the same env vars -- no credential_process script
 * needed.
 */

const RCLONE_CONFIG = "/config/rclone.conf";
const SOURCE_REMOTE = "seaweedfs-default";
const SOURCE_ENDPOINT =
  "http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333";
const RELAY_REMOTE = "seaweedfs-biscuit";
const RELAY_BUCKET = "seaweedfs-default-backup";
const OFFSITE_REMOTE = "b2";
const OFFSITE_BUCKET = "walnuts-seaweedfs-biscuit-backup-81f18e5";

type LogFields = Record<string, string>;

function log(level: string, msg: string, fields: LogFields = {}): void {
  const entry = {
    level,
    time: new Date().toISOString().replace(/\.\d{3}Z$/, "+0000"),
    msg,
    ...fields,
  };
  console.log(JSON.stringify(entry));
}

async function run(
  cmd: string[],
): Promise<{ success: boolean; stdout: string; stderr: string }> {
  const command = new Deno.Command(cmd[0], {
    args: cmd.slice(1),
    stdout: "piped",
    stderr: "piped",
  });
  const { success, stdout, stderr } = await command.output();
  return {
    success,
    stdout: new TextDecoder().decode(stdout),
    stderr: new TextDecoder().decode(stderr),
  };
}

async function runInherited(cmd: string[]): Promise<boolean> {
  const command = new Deno.Command(cmd[0], {
    args: cmd.slice(1),
    stdout: "inherit",
    stderr: "inherit",
  });
  const { success } = await command.output();
  return success;
}

async function listSourceBuckets(): Promise<string[]> {
  const result = await run([
    "rclone",
    "lsf",
    `${SOURCE_REMOTE}:`,
    "--dirs-only",
    `--config=${RCLONE_CONFIG}`,
  ]);
  if (!result.success) {
    log("error", "Failed to list source buckets", { error: result.stderr });
    Deno.exit(1);
  }
  return result.stdout
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .map((line) => line.replace(/\/$/, ""));
}

interface Tag {
  readonly Key: string;
  readonly Value: string;
}

function shouldSkipBackup(tagSet: readonly Tag[]): boolean {
  return tagSet.some((tag) => tag.Key === "skip-backup");
}

async function isBackupTarget(bucket: string): Promise<boolean> {
  const result = await run([
    "aws",
    "s3api",
    "get-bucket-tagging",
    "--endpoint-url",
    SOURCE_ENDPOINT,
    "--bucket",
    bucket,
  ]);
  if (result.success) {
    const tagSet = (JSON.parse(result.stdout).TagSet ?? []) as Tag[];
    if (shouldSkipBackup(tagSet)) {
      log("info", "Excluding bucket due to skip-backup tag", { bucket });
      return false;
    }
    log("info", "Including bucket in sync", { bucket });
    return true;
  }
  if (
    result.stderr.includes("NoSuchTagSet") ||
    result.stderr.includes("NoSuchTag")
  ) {
    log("info", "Including bucket without tags", { bucket });
    return true;
  }
  log("error", "Failed to read bucket tags", { bucket, error: result.stderr });
  Deno.exit(1);
}

async function rcloneSync(source: string, dest: string): Promise<void> {
  const success = await runInherited([
    "rclone",
    "sync",
    "--metrics-addr=:9250",
    `--config=${RCLONE_CONFIG}`,
    "-v",
    source,
    dest,
  ]);
  if (!success) {
    log("error", "Sync failed", { source, dest });
    log("error", "Backup process completed with errors");
    Deno.exit(1);
  }
}

async function main(): Promise<void> {
  log("info", "Starting backup process");

  const buckets = await listSourceBuckets();
  const backupBuckets: string[] = [];
  for (const bucket of buckets) {
    if (await isBackupTarget(bucket)) {
      backupBuckets.push(bucket);
    }
  }

  for (const bucket of backupBuckets) {
    const sourcePath = `${SOURCE_REMOTE}:${bucket}/`;
    const destPath = `${RELAY_REMOTE}:${RELAY_BUCKET}/${bucket}/`;
    log("info", "Sync started", { source: sourcePath, dest: destPath, bucket });
    await rcloneSync(sourcePath, destPath);
    log("info", "Sync completed successfully", {
      source: sourcePath,
      dest: destPath,
      bucket,
    });
  }

  for (const bucket of backupBuckets) {
    const sourcePath = `${RELAY_REMOTE}:${RELAY_BUCKET}/${bucket}/`;
    const b2Path = `${OFFSITE_REMOTE}:${OFFSITE_BUCKET}/${bucket}/`;
    log("info", "Offsite backup started", {
      source: sourcePath,
      dest: b2Path,
      bucket,
    });
    await rcloneSync(sourcePath, b2Path);
    log("info", "Offsite backup completed", {
      source: sourcePath,
      dest: b2Path,
      bucket,
    });
  }

  log("info", "Backup process completed successfully");
}

await main();
