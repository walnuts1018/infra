function(app, useSuffix=true)
  local dbName = std.strReplace(app.name, '-', '_');
  (import '../../../external-secret.libsonnet') {
    name: app.name + '-postgres',
    namespace: app.namespace,
    use_suffix: useSuffix,
    data: [
      {
        secretKey: 'postgres_password',
        remoteRef: {
          key: 'postgres_passwords',
          property: std.strReplace(app.name, '-', '_'),
        },
      },
    ],
    template_data: {
      DATABASE_URL: 'postgres://' + dbName + ':{{ .postgres_password }}@postgresql-default-rw.databases.svc.cluster.local:5432/' + dbName + '?pool_max_conns=2',
    },
  }
