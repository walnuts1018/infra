local identities = [
  {
    resourceName: 'mcl-playground',
    name: 'mcl_playground',
    policyName: 'mcl-playground-access-key',
    secretName: 'mcl-playground-s3-credentials',
    accessKeyField: 'AWS_ACCESS_KEY_ID',
    secretKeyField: 'AWS_SECRET_ACCESS_KEY',
    permissions: [
      {
        effect: 'Allow',
        actions: ['Read', 'Write', 'List', 'Delete'],
        buckets: ['mcl-playground'],
      },
    ],
  },
  {
    resourceName: 'mcl-playground-backup',
    name: 'mcl_playground_backup',
    policyName: 'mcl-playground-backup-access-key',
    secretName: 'mcl-playground-backup-seaweedfs-credentials',
    accessKeyField: 'AWS_ACCESS_KEY_ID',
    secretKeyField: 'AWS_SECRET_ACCESS_KEY',
    permissions: [
      {
        effect: 'Allow',
        actions: ['Read', 'List'],
        buckets: ['mcl-playground'],
      },
    ],
  },
];
{
  identities: identities,
  seaweedRef: {
    name: 'seaweedfs-default',
    namespace: 'seaweedfs',
  },
  forIdentity(name):: std.filter(function(identity) identity.name == name, identities)[0],
}
