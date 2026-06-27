local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
(externalSecret) {
  name: app.name,
  namespace: app.namespace,
  data: [
    {
      secretKey: 'scylladb_password',
      remoteRef: {
        key: 'scylladb',
        property: 'prfexample',
      },
    },
  ],
  template_data: {
    scylladb_username: 'prfexample',
    scylladb_password: '{{ .scylladb_password }}',
  },
}
