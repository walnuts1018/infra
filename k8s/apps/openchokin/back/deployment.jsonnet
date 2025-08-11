{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import '../app.json5').name + '-back',
    namespace: (import '../app.json5').namespace,
    labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-back' },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-back' },
    },
    template: {
      metadata: {
        labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-back' },
      },
      spec: {
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'openchokin-back',
            image: 'ghcr.io/walnuts1018/openchokin-back:v0.0.0-cd205cba77a922ba01009c04203a0e4b962a31d8-97',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 8080,
              },
            ],
            env: [
              {
                name: 'GIN_MODE',
                value: 'release',
              },
              {
                name: 'POSTGRES_ADMIN_USER',
                value: 'postgres',
              },
              {
                name: 'POSTGRES_ADMIN_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: (import '../external-secret.jsonnet').spec.target.name,
                    key: 'postgres-admin-password',
                  },
                },
              },
              {
                name: 'POSTGRES_USER',
                value: 'openchokin',
              },
              {
                name: 'POSTGRES_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: (import '../external-secret.jsonnet').spec.target.name,
                    key: 'postgres-user-password',
                  },
                },
              },
              {
                name: 'POSTGRES_DB',
                value: 'openchokin',
              },
              {
                name: 'POSTGRES_HOST',
                value: 'postgresql-default-rw.databases.svc.cluster.local',
              },
              {
                name: 'POSTGRES_PORT',
                value: '5432',
              },
            ],
            resources: {
              requests: {
                memory: '10Mi',
              },
              limits: {},
            },
          },
        ],
      },
    },
  },
}
