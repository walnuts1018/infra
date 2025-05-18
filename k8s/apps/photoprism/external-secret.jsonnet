{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ExternalSecret',
  metadata: {
    name: (import 'app.json5').name + '-' + std.md5(std.toString($.spec.data) + { spec: { target: { name: null } } })[0:6],
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    secretStoreRef: {
      name: 'onepassword',
      kind: 'ClusterSecretStore',
    },
    refreshInterval: '1m',
    target: {
      name: $.metadata.name,
      template: {
        engineVersion: 'v2',
        type: 'Opaque',
        data: {
          PHOTOPRISM_DATABASE_DSN: 'photoprism:{{ .dbpassword }}@tcp(photoprism-mariadb.photoprism.svc.cluster.local:3306)/photoprism?charset=utf8mb4,utf8&parseTime=true',
          PHOTOPRISM_ADMIN_PASSWORD: '{{ .adminpassword }}',
        },
      },
    },
    data: [
      {
        secretKey: 'adminpassword',
        remoteRef: {
          key: 'photoprism',
          property: 'admin-password',
        },
      },
      {
        secretKey: 'dbpassword',
        remoteRef: {
          key: 'photoprism',
          property: 'mariadb-photoprism-password',
        },
      },
    ],
  },
}
