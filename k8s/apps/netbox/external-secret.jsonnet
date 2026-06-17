[
  (import '../../components/external-secret.libsonnet') {
    name: 'netbox',
    use_suffix: false,
    data: [
      // Superuser credentials (keys must match what NetBox chart expects)
      {
        secretKey: 'superuser-password',
        remoteRef: {
          key: 'netbox',
          property: 'superuser-password',
        },
      },
      {
        secretKey: 'superuser-api-token',
        remoteRef: {
          key: 'netbox',
          property: 'superuser-api-token',
        },
      },
      // Application secret key (used by existingSecret)
      {
        secretKey: 'secret_key',
        remoteRef: {
          key: 'netbox',
          property: 'secret-key',
        },
      },
      // Database password
      {
        secretKey: 'db_password',
        remoteRef: {
          key: 'postgres_passwords',
          property: 'netbox',
        },
      },
      // SMTP password
      {
        secretKey: 'smtp_password',
        remoteRef: {
          key: 'resend',
          property: 'api-key',
        },
      },
    ],
    template_data: {
      // Superuser fields expected by NetBox chart's superuser.existingSecret
      password: '{{ .superuser-password }}',
      api_token: '{{ .superuser-api-token }}',
      // NetBox application secret key (expected by existingSecret)
      secret_key: '{{ .secret_key }}',
      // Database password
      'db-password': '{{ .db_password }}',
      // SMTP password
      'smtp-password': '{{ .smtp_password }}',
    },
  },
  (import '../../components/external-secret.libsonnet') {
    name: 'netbox-oidc-config',
    use_suffix: false,
    data: [
      {
        secretKey: 'client-id',
        remoteRef: {
          key: 'netbox',
          property: 'oidc-client-id',
        },
      },
      {
        secretKey: 'client-secret',
        remoteRef: {
          key: 'netbox',
          property: 'oidc-client-secret',
        },
      },
    ],
    template_data: {
      'oidc.yaml': "SOCIAL_AUTH_OIDC_KEY: '{{ .client-id }}'\nSOCIAL_AUTH_OIDC_SECRET: '{{ .client-secret }}'\nSOCIAL_AUTH_OIDC_OIDC_ENDPOINT: 'https://auth.walnuts.dev'",
    },
  },
]
