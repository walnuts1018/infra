{
  apiVersion: 'acid.zalan.do/v1',
  kind: 'postgresql',
  metadata: {
    name: 'test',
  },
  spec: {
    teamId: 'default',
    volume: {
      size: '1Gi',
      storageClass: 'longhorn',
    },
    numberOfInstances: 1,
    users: {
      postgres: [
        'superuser',
        'createdb',
      ],
      test: [],
    },
    databases: {
      [test]: test,
    },
    postgresql: {
      version: '17',
      parameters: {
        max_standby_archive_delay: '180s',
        max_standby_streaming_delay: '180s',
      },
    },
    resources: {
    },
    patroni: {
      pg_hba: [
        'local      all             all                             trust',
        'hostssl    all             +zalandos    127.0.0.1/32       pam',
        'host       all             all          127.0.0.1/32       md5',
        'hostssl    all             +zalandos    ::1/128            pam',
        'host       all             all          ::1/128            md5',
        'local      replication     standby                         trust',
        'hostssl    replication     standby      all                md5',
        'hostssl    all             +zalandos    all                pam',
        'hostssl    all             all          all                md5',
        'host       all             all          10.0.0.0/8      md5',
      ],
    },
    enableLogicalBackup: false,
  },
}
