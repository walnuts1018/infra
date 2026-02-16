local databases = (import 'databases.libsonnet');
local gen = function(database) std.mergePatch((import '../../components/external-secret.libsonnet') {
  use_suffix:: false,
  name: std.strReplace(database.user_name + '-db-password', '_', '-'),
  data: [
    {
      secretKey: 'password',
      remoteRef: {
        key: 'postgres_passwords',
        property: database.user_name,
      },
    },
  ],
}, {
  spec: {
    target: {
      template: {
        engineVersion: 'v2',
        type: 'kubernetes.io/basic-auth',
        data: {
          username: database.user_name,
          password: '{{ .password }}',
        },
      },
    },
  },
});

std.map(gen, databases)
