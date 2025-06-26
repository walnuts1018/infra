local appname = 'test';

{
  apiVersion: 'minio.min.io/v2',
  kind: 'Tenant',
  metadata: {
    name: appname,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: appname },
  },
  spec: {
    users: [
      {
        name: 'storage-user',
      },
    ],
    env: [
      {
        name: 'MINIO_ROOT_USER',
        valueFrom: {
          secretKeyRef: {
            name: (import 'external-secret.jsonnet').spec.target.name,
            key: 'rootUser',
          },
        },
      },
      {
        name: 'MINIO_ROOT_PASSWORD',
        valueFrom: {
          secretKeyRef: {
            name: (import 'external-secret.jsonnet').spec.target.name,
            key: 'rootPassword',
          },
        },
      },
      {
        name: 'MINIO_PROMETHEUS_AUTH_TYPE',
        value: 'public',
      },
    ],
    pools: [
      {
        servers: 3,
        name: appname + '-pool-0',
        volumesPerServer: 1,
        resources: {},
        volumeClaimTemplate: {
          spec: {
            accessModes: [
              'ReadWriteOnce',
            ],
            resources: {
              requests: {
                storage: '10Gi',
              },
            },
            storageClassName: 'longhorn',
          },
        },
        securityContext: {
          runAsUser: 1000,
          runAsGroup: 1000,
          runAsNonRoot: true,
          fsGroup: 1000,
          fsGroupChangePolicy: 'OnRootMismatch',
        },
        containerSecurityContext: {
          runAsUser: 1000,
          runAsGroup: 1000,
          runAsNonRoot: true,
          allowPrivilegeEscalation: false,
          capabilities: {
            drop: [
              'ALL',
            ],
          },
          seccompProfile: {
            type: 'RuntimeDefault',
          },
        },
      },
    ],
    requestAutoCert: true,
  },
}
