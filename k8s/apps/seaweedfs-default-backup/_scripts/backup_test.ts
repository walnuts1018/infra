import {
  canReconcileDeletion,
  extractAwsErrorCode,
  parseTaggingResponse,
  reconcileManifest,
  shouldSkipBackup,
  type BackupManifest,
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
  if (extractAwsErrorCode("An error occurred (NoSuchTagSet) when calling") !== "NoSuchTagSet") {
    throw new Error("NoSuchTagSet was not extracted");
  }
  if (extractAwsErrorCode("some text NoSuchTagSet in an unrelated message")) {
    throw new Error("arbitrary stderr text was accepted as an AWS error code");
  }
});

Deno.test("recognizes skip-backup tags", () => {
  if (!shouldSkipBackup([{ Key: "skip-backup", Value: "true" }])) {
    throw new Error("skip-backup tag was not recognized");
  }
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

Deno.test("suppresses deletion reconciliation after an observation failure", () => {
  if (canReconcileDeletion(false, true) || canReconcileDeletion(true, false)) {
    throw new Error("deletion reconciliation was allowed after an observation failure");
  }
});
