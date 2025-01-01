local usernames = (import 'users.libsonnet');
local gen = function(username) {
  apiVersion: 'external-secrets.io/v1beta1',
  kind: 'ExternalSecret',
  metadata: {
    name: '%s.default.credentials.postgresql.acid.zalan.do' % username,
  },
  spec: {
    data: [
      {
        remoteRef: {
          key: 'postgres_passwords',
          property: username,
        },
        secretKey: 'password',
      },
    ],
    refreshInterval: '1m',
    secretStoreRef: {
      kind: 'ClusterSecretStore',
      name: 'onepassword',
    },
    target: {
      name: $.metadata.name,
      template: {
        data: {
          username: username,
          password: '{{ .password }}',
        },
        engineVersion: 'v2',
        metadata: {
          labels: {
            application: 'spilo',
            'cluster-name': 'default',
            team: 'default',
          },
        },
        type: 'Opaque',
      },
    },
  },
};

std.map(gen, usernames)
