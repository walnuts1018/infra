(import '../../../components/external-secret.libsonnet') {
  name: 'photoprism-mariadb',
  use_suffix: false,
  data: [
    {
      secretKey: 'mariadb-root-password',
      remoteRef: {
        key: 'photoprism',
        property: 'mariadb-root-password',
      },
    },
    {
      secretKey: 'mariadb-replication-password',
      remoteRef: {
        key: 'photoprism',
        property: 'mariadb-replication-password',
      },
    },
    {
      secretKey: 'mariadb-password',
      remoteRef: {
        key: 'photoprism',
        property: 'mariadb-photoprism-password',
      },
    },
  ],
}
