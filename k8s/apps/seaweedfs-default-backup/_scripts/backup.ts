#!/usr/bin/env -S deno run --allow-run --allow-env --allow-read --allow-write=/tmp
/**
 * Mirrors each selected source bucket to the SeaweedFS relay and immediately
 * mirrors that bucket to B2. A manifest keeps bucket disappearance separate
 * from a transient source/tagging failure and delays prefix deletion by 30 days.
 */

const RCLONE_CONFIG = "/config/rclone.conf";
const LOCAL_CA_CERT = "/etc/ssl/certs/trust-bundle.pem";
const MANIFEST_FILE = "/tmp/backup-manifest.json";
const MANIFEST_OBJECT = "_backup/manifest.json";
const SOURCE_REMOTE = "seaweedfs-default";
const SOURCE_ENDPOINT =
  "http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333";
const RELAY_REMOTE = "seaweedfs-biscuit";
const RELAY_BUCKET = "seaweedfs-default-backup";
const OFFSITE_REMOTE = "b2";
const OFFSITE_BUCKET = "walnuts-seaweedfs-biscuit-backup-81f18e5";
const RETENTION_DAYS = 30;
const DAY_MS = 24 * 60 * 60 * 1000;

export interface Tag {
  readonly Key: string;
  readonly Value: string;
}

export interface TaggingResponse {
  readonly TagSet: readonly Tag[];
}

export interface BackupManifestEntry {
  readonly sourceBucket: string;
  readonly destinationPrefix: string;
  readonly lastSeenAt: string;
  readonly missingSince?: string;
  readonly skipped: boolean;
}

export interface BackupManifest {
  readonly version: 1;
  readonly updatedAt: string;
  readonly buckets: readonly BackupManifestEntry[];
}

export interface ObservedBucket {
  readonly name: string;
  readonly skipped: boolean;
}

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === "object" && value !== null && !Array.isArray(value);

const isNonEmptyString = (value: unknown): value is string =>
  typeof value === "string" && value.length > 0;

const isSafeBucketName = (value: unknown): value is string =>
  typeof value === "string" &&
  /^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$/.test(value) &&
  !value.includes("..") && !value.includes(".-") && !value.includes("-.");

const isRfc3339Utc = (value: unknown): value is string =>
  typeof value === "string" &&
  /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{3})?Z$/.test(value) &&
  !Number.isNaN(Date.parse(value));

export function isTaggingResponse(value: unknown): value is TaggingResponse {
  return isRecord(value) && Array.isArray(value.TagSet) && value.TagSet.every(
    (tag) =>
      isRecord(tag) && isNonEmptyString(tag.Key) &&
      typeof tag.Value === "string",
  );
}

export function parseTaggingResponse(text: string): TaggingResponse {
  const value: unknown = JSON.parse(text);
  if (!isTaggingResponse(value)) {
    throw new Error("AWS tagging response has an invalid shape");
  }
  return value;
}

export function expectedDestinationPrefix(sourceBucket: string): string {
  return `${sourceBucket}/`;
}

function isSafeDestinationPrefix(
  sourceBucket: string,
  value: unknown,
): value is string {
  return isNonEmptyString(value) &&
    value === expectedDestinationPrefix(sourceBucket) &&
    !value.startsWith("_backup/");
}

export function isBackupManifest(value: unknown): value is BackupManifest {
  return isRecord(value) && value.version === 1 &&
    isRfc3339Utc(value.updatedAt) && Array.isArray(value.buckets) &&
    value.buckets.every((entry) => {
      if (!isRecord(entry)) return false;
      return isSafeBucketName(entry.sourceBucket) &&
        isSafeDestinationPrefix(entry.sourceBucket, entry.destinationPrefix) &&
        isRfc3339Utc(entry.lastSeenAt) &&
        (entry.missingSince === undefined ||
          isRfc3339Utc(entry.missingSince)) &&
        typeof entry.skipped === "boolean";
    });
}

export function parseBackupManifest(text: string): BackupManifest {
  const value: unknown = JSON.parse(text);
  if (!isBackupManifest(value)) {
    throw new Error("Backup manifest has an invalid shape");
  }
  return value;
}

export function shouldSkipBackup(tagSet: readonly Tag[]): boolean {
  return tagSet.some((tag) =>
    tag.Key === "skip-backup" && tag.Value === "true"
  );
}

export function extractAwsErrorCode(stderr: string): string | undefined {
  const xmlCode = stderr.match(/<Code>([A-Za-z][A-Za-z0-9]+)<\/Code>/)?.[1];
  if (xmlCode) return xmlCode;
  return stderr.match(/An error occurred \(([A-Za-z][A-Za-z0-9]+)\)/)?.[1];
}

export function canReconcileDeletion(
  sourceListingSucceeded: boolean,
  taggingSucceeded: boolean,
): boolean {
  return sourceListingSucceeded && taggingSucceeded;
}

export function remotePath(remote: string, object: string): string {
  if (remote.length === 0 || object.length === 0) {
    throw new Error("Remote and object must be non-empty");
  }
  const base = remote.replace(/\/+$/, "");
  const separator = base.includes(":") ? "/" : ":";
  return `${base}${separator}${object.replace(/^\/+/, "")}`;
}

export function reconcileManifest(
  manifest: BackupManifest,
  observed: readonly ObservedBucket[],
  now: string,
  retentionDays = RETENTION_DAYS,
): { manifest: BackupManifest; expired: readonly BackupManifestEntry[] } {
  if (!isRfc3339Utc(now)) {
    throw new Error("Manifest timestamp must be RFC3339 UTC");
  }
  const observedByName = new Map(
    observed.map((bucket) => [bucket.name, bucket]),
  );
  const expired: BackupManifestEntry[] = [];
  const entries = manifest.buckets.flatMap((entry) => {
    const current = observedByName.get(entry.sourceBucket);
    if (current) {
      return [{
        sourceBucket: entry.sourceBucket,
        destinationPrefix: expectedDestinationPrefix(entry.sourceBucket),
        lastSeenAt: now,
        skipped: current.skipped,
      }];
    }
    const missingSince = entry.missingSince ?? now;
    if (Date.parse(now) - Date.parse(missingSince) >= retentionDays * DAY_MS) {
      expired.push({ ...entry, missingSince });
      return [];
    }
    return [{ ...entry, missingSince }];
  });

  for (const current of observed) {
    if (
      !manifest.buckets.some((entry) => entry.sourceBucket === current.name)
    ) {
      entries.push({
        sourceBucket: current.name,
        destinationPrefix: expectedDestinationPrefix(current.name),
        lastSeenAt: now,
        skipped: current.skipped,
      });
    }
  }

  return {
    manifest: { version: 1, updatedAt: now, buckets: entries },
    expired,
  };
}

interface CommandResult {
  readonly success: boolean;
  readonly stdout: string;
  readonly stderr: string;
}

async function run(cmd: readonly string[]): Promise<CommandResult> {
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

async function runInherited(cmd: readonly string[]): Promise<void> {
  const command = new Deno.Command(cmd[0], {
    args: cmd.slice(1),
    stdout: "inherit",
    stderr: "inherit",
  });
  const { success } = await command.output();
  if (!success) throw new Error(`Command failed: ${cmd.join(" ")}`);
}

function rcloneArgs(...args: string[]): string[] {
  return [
    "rclone",
    ...args,
    `--config=${RCLONE_CONFIG}`,
    `--ca-cert=${LOCAL_CA_CERT}`,
  ];
}

async function listSourceBuckets(): Promise<string[]> {
  const result = await run(
    rcloneArgs("lsf", `${SOURCE_REMOTE}:/`, "--dirs-only"),
  );
  if (!result.success) {
    throw new Error(`Failed to list source buckets: ${result.stderr}`);
  }
  const buckets = result.stdout
    .split("\n")
    .map((line) => line.trim().replace(/\/$/, ""))
    .filter((bucket) => bucket.length > 0);
  if (!buckets.every(isSafeBucketName)) {
    throw new Error("Source bucket listing contains an invalid bucket name");
  }
  return buckets;
}

async function getBucketTags(bucket: string): Promise<readonly Tag[]> {
  const result = await run([
    "aws",
    "s3api",
    "get-bucket-tagging",
    "--endpoint-url",
    SOURCE_ENDPOINT,
    "--bucket",
    bucket,
  ]);
  if (result.success) return parseTaggingResponse(result.stdout).TagSet;
  if (extractAwsErrorCode(result.stderr) === "NoSuchTagSet") return [];
  throw new Error(`Failed to read tags for ${bucket}: ${result.stderr}`);
}

async function readRemoteManifest(
  remote: string,
): Promise<BackupManifest | undefined> {
  const result = await run(
    rcloneArgs("cat", remotePath(remote, MANIFEST_OBJECT)),
  );
  if (!result.success) {
    const directory = await run(
      rcloneArgs("lsf", remotePath(remote, "_backup/"), "--files-only"),
    );
    if (!directory.success) {
      throw new Error(
        `Failed to read backup manifest from ${remote}: ${result.stderr}`,
      );
    }
    if (
      directory.stdout.split("\n").some((line) =>
        line.trim() === "manifest.json"
      )
    ) {
      throw new Error(
        `Backup manifest exists but could not be read from ${remote}: ${result.stderr}`,
      );
    }
    return undefined;
  }
  return parseBackupManifest(result.stdout);
}

async function loadManifest(): Promise<BackupManifest> {
  const relay = await readRemoteManifest(`${RELAY_REMOTE}:${RELAY_BUCKET}`);
  if (relay) return relay;
  const offsite = await readRemoteManifest(
    `${OFFSITE_REMOTE}:${OFFSITE_BUCKET}`,
  );
  if (offsite) return offsite;
  return { version: 1, updatedAt: new Date(0).toISOString(), buckets: [] };
}

async function saveManifest(manifest: BackupManifest): Promise<void> {
  await Deno.writeTextFile(
    MANIFEST_FILE,
    JSON.stringify(manifest, null, 2) + "\n",
  );
  await copyManifestToDestinations(
    MANIFEST_FILE,
    [
      remotePath(`${RELAY_REMOTE}:${RELAY_BUCKET}`, MANIFEST_OBJECT),
      remotePath(`${OFFSITE_REMOTE}:${OFFSITE_BUCKET}`, MANIFEST_OBJECT),
    ],
    async (source, destination) => {
      await runInherited(rcloneArgs("copyto", source, destination));
    },
  );
}

async function syncBucket(source: string, destination: string): Promise<void> {
  await runInherited(rcloneArgs("sync", source, destination, "-v"));
}

export type SyncOperation = (
  source: string,
  destination: string,
) => Promise<void>;

export async function syncBucketPair(
  source: string,
  relay: string,
  offsite: string,
  sync: SyncOperation,
): Promise<void> {
  await sync(source, relay);
  await sync(relay, offsite);
}

export type CopyOperation = (
  source: string,
  destination: string,
) => Promise<void>;

export async function copyManifestToDestinations(
  manifestFile: string,
  destinations: readonly string[],
  copy: CopyOperation,
): Promise<void> {
  for (const destination of destinations) {
    await copy(manifestFile, destination);
  }
}

async function deletePrefix(remote: string, prefix: string): Promise<void> {
  await runInherited(rcloneArgs("purge", remotePath(remote, prefix)));
}

async function main(): Promise<void> {
  const now = new Date().toISOString();
  let sourceListingSucceeded = false;
  let taggingSucceeded = false;
  const sourceBuckets = await listSourceBuckets();
  sourceListingSucceeded = true;
  const observed: ObservedBucket[] = [];

  for (const bucket of sourceBuckets) {
    const skipped = shouldSkipBackup(await getBucketTags(bucket));
    observed.push({ name: bucket, skipped });
    if (skipped) {
      log("info", "Keeping bucket excluded by skip-backup tag", { bucket });
      continue;
    }

    const sourcePath = remotePath(SOURCE_REMOTE, `${bucket}/`);
    const relayPath = remotePath(
      `${RELAY_REMOTE}:${RELAY_BUCKET}`,
      `${bucket}/`,
    );
    const offsitePath = remotePath(
      `${OFFSITE_REMOTE}:${OFFSITE_BUCKET}`,
      `${bucket}/`,
    );
    log("info", "Relay and B2 sync started", {
      bucket,
      source: sourcePath,
      relay: relayPath,
      offsite: offsitePath,
    });
    await syncBucketPair(sourcePath, relayPath, offsitePath, syncBucket);
  }
  taggingSucceeded = true;

  if (!canReconcileDeletion(sourceListingSucceeded, taggingSucceeded)) {
    throw new Error(
      "Deletion reconciliation requires complete source and tag observations",
    );
  }
  const currentManifest = await loadManifest();
  const { manifest, expired } = reconcileManifest(
    currentManifest,
    observed,
    now,
  );
  for (const entry of expired) {
    log("info", "Deleting expired bucket prefix", {
      bucket: entry.sourceBucket,
      missingSince: entry.missingSince ?? "",
    });
    const prefix = expectedDestinationPrefix(entry.sourceBucket);
    await deletePrefix(`${RELAY_REMOTE}:${RELAY_BUCKET}`, prefix);
    await deletePrefix(`${OFFSITE_REMOTE}:${OFFSITE_BUCKET}`, prefix);
  }
  await saveManifest(manifest);
  log("info", "Backup process completed successfully", {
    buckets: String(observed.length),
    expired: String(expired.length),
  });
}

function log(
  level: string,
  msg: string,
  fields: Record<string, string> = {},
): void {
  console.log(JSON.stringify({
    level,
    time: new Date().toISOString(),
    msg,
    ...fields,
  }));
}

if (import.meta.main) {
  try {
    await main();
  } catch (error) {
    log("error", "Backup process failed", {
      error: error instanceof Error ? error.message : String(error),
    });
    Deno.exit(1);
  }
}
