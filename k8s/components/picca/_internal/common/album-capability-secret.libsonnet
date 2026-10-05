function(app, useSuffix=true)
  (import '../../../external-secret.libsonnet') {
    name: app.name + '-album-capability',
    namespace: app.namespace,
    use_suffix: useSuffix,
    data: [
      {
        secretKey: 'capability_keys',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: app.name + '-album-capability-keys',
        },
      },
      {
        secretKey: 'capability_active_key_id',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: app.name + '-album-capability-active-key-id',
        },
      },
    ],
    template_data: {
      ALBUM_CAPABILITY_KEYS: '{{ .capability_keys }}',
      ALBUM_CAPABILITY_ACTIVE_KEY_ID: '{{ .capability_active_key_id }}',
    },
  }
