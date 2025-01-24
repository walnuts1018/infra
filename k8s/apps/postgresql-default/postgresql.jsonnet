local usernames = (import 'users.libsonnet');
local databases = (import 'databases.libsonnet');

{
  apiVersion: 'acid.zalan.do/v1',
  kind: 'postgresql',
  metadata: {
    name: 'default',
  },
  spec: {
    teamId: 'default',
    volume: {
      size: '20Gi',
      storageClass: 'longhorn',
    },
    numberOfInstances: 3,
    users: {
      [username]: []
      for username in usernames
    } + {
      postgres: [
        'superuser',
        'createdb',
      ],
      test: [],
    },
    databases: {
      [database.db_name]: database.user_name
      for database in databases
    },
    postgresql: {
      version: '17',
      parameters: {
        max_standby_archive_delay: '180s',
        max_standby_streaming_delay: '180s',
      },
    },
    resources: {
      requests: {
        cpu: '10m',
        memory: '600Mi',
      },
      limits: {
        cpu: '2',
        memory: '2Gi',
      },
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
    nodeAffinity: {
      preferredDuringSchedulingIgnoredDuringExecution: [
        {
          weight: 100,
          preference: {
            matchExpressions: [
              {
                key: 'kubernetes.io/arch',
                operator: 'In',
                values: [
                  'amd64',
                ],
              },
            ],
          },
        },
        {
          weight: 10,
          preference: {
            matchExpressions: [
              {
                key: 'kubernetes.io/hostname',
                operator: 'NotIn',
                values: [
                  'donut',
                ],
              },
            ],
          },
        },
      ],
    },
    enableLogicalBackup: true,
    logicalBackupRetention: '1 week',
    logicalBackupSchedule: '0 18 * * *',
  },
}
