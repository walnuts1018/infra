{
  env: [
    {
      name: 'SCYLLA_CA_CERT_PATH',
      value: '/etc/certs/scylla-db/ca.crt',
    },
    {
      name: 'SCYLLA_CLIENT_CERT_PATH',
      value: '/etc/certs/scylla-db-client/tls.crt',
    },
    {
      name: 'SCYLLA_CLIENT_KEY_PATH',
      value: '/etc/certs/scylla-db-client/tls.key',
    },
  ],
  volumes: [
    {
      name: 'scylla-db-ca-cert',
      configMap: {
        name: (import 'configmap-scylladb-ca.jsonnet').metadata.name,
        items: [
          {
            key: 'ca.crt',
            path: 'ca.crt',
          },
        ],
      },
    },
    {
      name: 'scylla-db-client-cert',
      secret: {
        secretName: (import 'scylla-client-cert-external-secret.jsonnet').spec.target.name,
        items: [
          {
            key: 'tls.crt',
            path: 'tls.crt',
          },
          {
            key: 'tls.key',
            path: 'tls.key',
          },
        ],
      },
    },
  ],
  volumeMounts: [
    {
      name: 'scylla-db-ca-cert',
      mountPath: '/etc/certs/scylla-db',
      readOnly: true,
    },
    {
      name: 'scylla-db-client-cert',
      mountPath: '/etc/certs/scylla-db-client',
      readOnly: true,
    },
  ],
}
