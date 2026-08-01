local externalSecrets = import 'external-secrets.libsonnet';
[
  externalSecrets.filerConfig,
  externalSecrets.s3Credentials,
]
