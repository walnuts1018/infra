local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';

[
  (externalSecret) {
    name: app.name + '-database',
    namespace: app.namespace,
    use_suffix: false,
    data: [
      {
        secretKey: 'password',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'dependency-track-database-password',
        },
      },
    ],
    template_data: {
      username: 'dependency_track',
      password: '{{ .password }}',
    },
  },
  (externalSecret) {
    name: app.name + '-kek',
    namespace: app.namespace,
    use_suffix: false,
    data: [
      {
        secretKey: 'kek',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'dependency-track-kek',
        },
      },
    ],
  },
  (externalSecret) {
    name: app.name + '-admin',
    namespace: app.namespace,
    use_suffix: false,
    data: [
      {
        secretKey: 'password',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'dependency-track-admin-password',
        },
      },
    ],
  },
  (externalSecret) {
    name: app.name + '-oidc',
    namespace: app.namespace,
    use_suffix: false,
    data: [
      {
        secretKey: 'client-id',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'dependency-track-client-id',
        },
      },
      {
        secretKey: 'group',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'dependency-track-oidc-group',
        },
      },
    ],
  },
]
