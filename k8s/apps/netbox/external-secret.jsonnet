[
  (import '../../components/external-secret.libsonnet') {
    name: 'netbox',
    use_suffix: false,
    data: [
      {
        secretKey: 'superuser_password',
        remoteRef: {
          key: 'netbox',
          property: 'superuser-password',
        },
      },
      {
        secretKey: 'superuser_api_token',
        remoteRef: {
          key: 'netbox',
          property: 'superuser-api-token',
        },
      },
      {
        secretKey: 'secret_key',
        remoteRef: {
          key: 'netbox',
          property: 'secret_key',
        },
      },
      {
        secretKey: 'api_token_peppers',
        remoteRef: {
          key: 'netbox',
          property: 'api_token_peppers',
        },
      },
      {
        secretKey: 'db_password',
        remoteRef: {
          key: 'postgres_passwords',
          property: 'netbox',
        },
      },
      {
        secretKey: 'smtp_password',
        remoteRef: {
          key: 'resend',
          property: 'api-key',
        },
      },
    ],
    template_data: {
      username: 'netbox-admin',
      email: 'netbox-admin@walnuts.dev',
      password: '{{ .superuser_password }}',
      api_token: '{{ .superuser_api_token }}',
      secret_key: '{{ .secret_key }}',
      api_token_peppers: '{{ .api_token_peppers }}',
      'db-password': '{{ .db_password }}',
      'smtp-password': '{{ .smtp_password }}',
    },
  },
  (import '../../components/external-secret.libsonnet') {
    name: 'netbox-oidc-config',
    use_suffix: false,
    data: [
      {
        secretKey: 'client_id',
        remoteRef: {
          key: 'netbox',
          property: 'oidc-client-id',
        },
      },
      {
        secretKey: 'client_secret',
        remoteRef: {
          key: 'netbox',
          property: 'oidc-client-secret',
        },
      },
    ],
    template_data: {
      'oidc.yaml': "SOCIAL_AUTH_OIDC_KEY: '{{ .client_id }}'\nSOCIAL_AUTH_OIDC_SECRET: '{{ .client_secret }}'\nSOCIAL_AUTH_OIDC_OIDC_ENDPOINT: 'https://auth.walnuts.dev'",
    },
  },
]
