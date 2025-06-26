{
  apiVersion: 'minio.min.io/v2',
  kind: 'Tenant',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    users: [
      {
        name: 'storage-user',
      },
    ],
    configuration: {
      name: (import 'storage-configuration.jsonnet').spec.target.name,
    },
    env: [],
    pools: [
      {
        servers: 4,
        name: (import 'app.json5').name + '-pool',
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
