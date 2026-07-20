local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local externalSecret = import '../external-secret.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-back',
    namespace: app.namespace,
    labels: (labels)(app.name + '-back'),
  },
  spec: {
    selector: {
      matchLabels: (labels)(app.name + '-back'),
    },
    template: {
      metadata: {
        labels: (labels)(app.name + '-back'),
      },
      spec: {
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'openchokin-back',
            resizePolicy: [
              {
                resourceName: 'cpu',
                restartPolicy: 'NotRequired',
              },
              {
                resourceName: 'memory',
                restartPolicy: 'RestartContainer',
              },
            ],
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
                    name: externalSecret.spec.target.name,
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
                    name: externalSecret.spec.target.name,
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
                cpu: '20m',
                memory: '64Mi',
              },
              limits: {
                cpu: '100m',
                memory: '128Mi',
              },
            },
          },
        ],
      },
    },
  },
}
