function(app, useSuffix=true)
  (import '../../../external-secret.libsonnet') {
    name: app.name + '-oidc',
    namespace: app.namespace,
    use_suffix: useSuffix,
    data: [
      {
        secretKey: 'oidc_client_id',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: app.name + '-client-id',
        },
      },
      {
        secretKey: 'oidc_client_secret',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: app.name + '-client-secret',
        },
      },
    ],
    template_data: {
      OIDC_CLIENT_ID: '{{ .oidc_client_id }}',
      OIDC_CLIENT_SECRET: '{{ .oidc_client_secret }}',
    },
  }
