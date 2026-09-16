local gen = function(database) std.mergePatch((import '../../components/external-secret.libsonnet') {
  use_suffix:: false,
  name: std.strReplace(database.user_name + '-db-password', '_', '-'),
  data: [
    {
      secretKey: 'password',
      remoteRef: {
        key: if 'secret_source_key' in database then database.secret_source_key else 'postgres_passwords',
        property: if 'secret_source_property' in database then database.secret_source_property else database.user_name,
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
std.map(gen, (import 'databases.libsonnet'))
