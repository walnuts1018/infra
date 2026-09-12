import {
  type BackupManifest,
  canReconcileDeletion,
  copyManifestToDestinations,
  extractAwsErrorCode,
  parseBackupManifest,
  parseTaggingResponse,
  reconcileManifest,
  remotePath,
  shouldSkipBackup,
  syncBucketPair,
} from "./backup.ts";

const manifest: BackupManifest = {
  version: 1,
  updatedAt: "2026-01-01T00:00:00Z",
  buckets: [{
    sourceBucket: "photos",
    destinationPrefix: "photos/",
    lastSeenAt: "2026-01-01T00:00:00Z",
    skipped: false,
  }],
};

Deno.test("rejects malformed tagging JSON", () => {
  let thrown = false;
  try {
    parseTaggingResponse('{"TagSet":[{"Key":"skip-backup"}]}');
  } catch {
    thrown = true;
  }
  if (!thrown) throw new Error("malformed tagging response was accepted");
});

Deno.test("accepts only the standard NoSuchTagSet error code", () => {
  if (
    extractAwsErrorCode("An error occurred (NoSuchTagSet) when calling") !==
      "NoSuchTagSet"
  ) {
    throw new Error("NoSuchTagSet was not extracted");
  }
  if (extractAwsErrorCode("some text NoSuchTagSet in an unrelated message")) {
    throw new Error("arbitrary stderr text was accepted as an AWS error code");
  }
  if (
    extractAwsErrorCode("<Error><Code>AccessDenied</Code></Error>") !==
      "AccessDenied"
  ) {
    throw new Error("XML AWS error code was not extracted");
  }
});

Deno.test("recognizes skip-backup tags", () => {
  if (!shouldSkipBackup([{ Key: "skip-backup", Value: "true" }])) {
    throw new Error("skip-backup tag was not recognized");
  }
  if (shouldSkipBackup([{ Key: "skip-backup", Value: "false" }])) {
    throw new Error("skip-backup=false must not exclude a bucket");
  }
});

Deno.test("joins an rclone remote and object with one separator", () => {
  if (
    remotePath(
      "seaweedfs-biscuit:seaweedfs-default-backup",
      "_backup/manifest.json",
    ) !==
      "seaweedfs-biscuit:seaweedfs-default-backup/_backup/manifest.json"
  ) {
    throw new Error("remote object path was assembled incorrectly");
  }
  if (
    remotePath("seaweedfs-default", "photos/") !== "seaweedfs-default:photos/"
  ) {
    throw new Error("remote name and bucket path were assembled incorrectly");
  }
  if (remotePath("b2:bucket/", "/photos/") !== "b2:bucket/photos/") {
    throw new Error("remote object path did not normalize separators");
  }
});

Deno.test("rejects a manifest destination outside its source bucket", () => {
  const malicious = {
    ...manifest,
    buckets: [{ ...manifest.buckets[0], destinationPrefix: "_backup/" }],
  };
  let thrown = false;
  try {
    parseBackupManifest(JSON.stringify(malicious));
  } catch {
    thrown = true;
  }
  if (!thrown) throw new Error("unsafe destination prefix was accepted");
});

Deno.test("does not delete a bucket immediately after disappearance", () => {
  const result = reconcileManifest(manifest, [], "2026-01-02T00:00:00Z");
  if (result.expired.length !== 0) throw new Error("bucket expired too early");
  if (result.manifest.buckets[0]?.missingSince !== "2026-01-02T00:00:00Z") {
    throw new Error("missingSince was not recorded");
  }
});

Deno.test("deletes a bucket after the retention period", () => {
  const missing: BackupManifest = {
    ...manifest,
    buckets: [{ ...manifest.buckets[0], missingSince: "2026-01-01T00:00:00Z" }],
  };
  const result = reconcileManifest(missing, [], "2026-01-31T00:00:00Z");
  if (result.expired.length !== 1 || result.manifest.buckets.length !== 0) {
    throw new Error("bucket was not expired after 30 days");
  }
});

Deno.test("resets missingSince when a bucket reappears", () => {
  const missing: BackupManifest = {
    ...manifest,
    buckets: [{ ...manifest.buckets[0], missingSince: "2026-01-01T00:00:00Z" }],
  };
  const result = reconcileManifest(
    missing,
    [{ name: "photos", skipped: false }],
    "2026-01-20T00:00:00Z",
  );
  if (result.manifest.buckets[0]?.missingSince !== undefined) {
    throw new Error("missingSince was not cleared after bucket reappearance");
  }
});

Deno.test("does not start the B2 sync after the relay sync fails", async () => {
  const calls: string[] = [];
  let thrown = false;
  try {
    await syncBucketPair(
      "source",
      "relay",
      "offsite",
      async (source, destination) => {
        calls.push(`${source}->${destination}`);
        throw new Error("relay failed");
      },
    );
  } catch {
    thrown = true;
  }
  if (!thrown || calls.join(",") !== "source->relay") {
    throw new Error("B2 sync was started after relay failure");
  }
});

Deno.test("propagates a B2 sync failure after a successful relay sync", async () => {
  const calls: string[] = [];
  let thrown = false;
  try {
    await syncBucketPair(
      "source",
      "relay",
      "offsite",
      async (source, destination) => {
        calls.push(`${source}->${destination}`);
        if (destination === "offsite") throw new Error("B2 failed");
      },
    );
  } catch {
    thrown = true;
  }
  if (!thrown || calls.join(",") !== "source->relay,relay->offsite") {
    throw new Error("B2 sync failure was not propagated");
  }
});

Deno.test("does not save the B2 manifest after relay manifest save fails", async () => {
  const calls: string[] = [];
  let thrown = false;
  try {
    await copyManifestToDestinations(
      "manifest",
      ["relay", "offsite"],
      async (_, destination) => {
        calls.push(destination);
        throw new Error("relay manifest save failed");
      },
    );
  } catch {
    thrown = true;
  }
  if (!thrown || calls.join(",") !== "relay") {
    throw new Error("B2 manifest save was started after relay failure");
  }
});

Deno.test("propagates a B2 manifest save failure after relay success", async () => {
  const calls: string[] = [];
  let thrown = false;
  try {
    await copyManifestToDestinations(
      "manifest",
      ["relay", "offsite"],
      async (_, destination) => {
        calls.push(destination);
        if (destination === "offsite") {
          throw new Error("B2 manifest save failed");
        }
      },
    );
  } catch {
    thrown = true;
  }
  if (!thrown || calls.join(",") !== "relay,offsite") {
    throw new Error("B2 manifest save failure was not propagated");
  }
});

Deno.test("suppresses deletion reconciliation after an observation failure", () => {
  if (canReconcileDeletion(false, true) || canReconcileDeletion(true, false)) {
    throw new Error(
      "deletion reconciliation was allowed after an observation failure",
    );
  }
});
