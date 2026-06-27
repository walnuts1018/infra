local externalSecret = import '../../components/external-secret.libsonnet';
local oidc = importstr './_config/oidc.py';
local diode = importstr './_config/diode.yaml';
[
  (externalSecret) {
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
        secretKey: 'api_token_peppers1',
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
      {
        secretKey: 'valkey_password',
        remoteRef: {
          key: 'netbox',
          property: 'valkey_password',
        },
      },
    ],
    template_data: {
      username: 'netbox-admin',
      email: 'netbox-admin@walnuts.dev',
      password: '{{ .superuser_password }}',
      api_token: '{{ .superuser_api_token }}',
      secret_key: '{{ .secret_key }}',
      api_token_peppers: '{"1": "{{ .api_token_peppers1 }}"}',
      'db-password': '{{ .db_password }}',
      'smtp-password': '{{ .smtp_password }}',
      valkey_password: '{{ .valkey_password }}',
    },
  },
  (externalSecret) {
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
      'oidc.py': (oidc),
    },
  },
  (externalSecret) {
    name: 'netbox-diode-config',
    use_suffix: false,
    data: [
      {
        secretKey: 'netbox_to_diode_client_secret',
        remoteRef: {
          key: 'diode',
          property: 'netbox_to_diode_client_secret',
        },
      },
    ],
    template_data: {
      'diode.yaml': (diode),
    },
  },
]
