local externalSecrets = import 'external-secrets.libsonnet';
[
  externalSecrets.filerConfig,
] + externalSecrets.externalCredentialSecrets
