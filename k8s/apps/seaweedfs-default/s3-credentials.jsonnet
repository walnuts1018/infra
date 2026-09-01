local app = import 'app.json5';
local config = import 'config.libsonnet';

// The SeaweedFS S3Credentials operator owns whatever Secret it is pointed at:
// it adopts an existing non-empty accessKey/secretKey pair as-is, or
// generates and writes its own if the fields are empty. Pointing it at each
// consuming app's own ExternalSecret-managed Secret (rather than a Secret
// shared across identities) lets that Secret stay the single source of
// truth, instead of racing another controller for ownership of a shared one.
local appOwnedTargets = {
  maps_rclone: {
    namespace: 'maps',
    secretName: (import '../maps/external-secret.jsonnet').spec.target.name,
    accessKeyField: 'RCLONE_CONFIG_SEAWEEDMAPS_ACCESS_KEY_ID',
    secretKeyField: 'RCLONE_CONFIG_SEAWEEDMAPS_SECRET_ACCESS_KEY',
  },
  stalwart: {
    namespace: 'stalwart',
    secretName: (import '../stalwart/external-secret.jsonnet').spec.target.name,
    accessKeyField: 's3_access_key',
    secretKeyField: 's3_secret_access_key',
  },
  oekaki_dengon_game: {
    namespace: 'oekaki-dengon-game',
    secretName: (import '../oekaki-dengon-game/external-secret.jsonnet').spec.target.name,
    accessKeyField: 'minio-access-key',
    secretKeyField: 'minio-secret-key',
  },
  visual_regression_tracker: {
    namespace: 'visual-regression-tracker',
    secretName: (import '../visual-regression-tracker/external-secret.jsonnet').spec.target.name,
    accessKeyField: 'AWS_ACCESS_KEY_ID',
    secretKeyField: 'AWS_SECRET_ACCESS_KEY',
  },
};

// Identities without a consuming app (e.g. terraform, mac_hatena) get their
// own Secret managed alongside this app; see external-secrets.libsonnet.
local targets = appOwnedTargets + (import 'external-secrets.libsonnet').selfManagedCredentialTargets;

[
  {
    apiVersion: 'seaweed.seaweedfs.com/v1',
    kind: 'S3Credentials',
    metadata: {
      name: identity.resourceName,
      namespace: app.namespace,
    },
    spec: {
      seaweedRef: {
        name: app.name,
      },
      identityRef: {
        name: identity.resourceName,
      },
      secretRef: {
        name: targets[identity.name].secretName,
        namespace: targets[identity.name].namespace,
        accessKeyField: targets[identity.name].accessKeyField,
        secretKeyField: targets[identity.name].secretKeyField,
      },
      reclaimPolicy: 'Retain',
    },
  }
  for identity in config.identities
  if std.objectHas(targets, identity.name)
]
