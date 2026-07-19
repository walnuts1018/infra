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
        imagePullSecrets: [
          {
            name: 'ghcr-login-secret',
          },
        ],
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'oekaki-dengon-game-back',
            image: 'ghcr.io/kmc-jp/oekaki-dengon-game-back:v0.0.0-a6d6d6e7d66e6d0dfafbf416b462be908b208489-13',
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
                value: 'oekaki_dengon_game',
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
                value: 'oekaki_dengon_game',
              },
              {
                name: 'POSTGRES_HOST',
                value: 'postgresql-default-rw.databases.svc.cluster.local',
              },
              {
                name: 'POSTGRES_PORT',
                value: '5432',
              },
              {
                name: 'MINIO_ENDPOINT',
                value: 'minio.walnuts.dev',
              },
              {
                name: 'MINIO_ACCESS_KEY',
                value: 'oekaki_dengon_game',
              },
              {
                name: 'MINIO_SECRET_KEY',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'minio-secret-key',
                  },
                },
              },
              {
                name: 'MINIO_BUCKET',
                value: 'oekaki-dengon-game',
              },
              {
                name: 'MINIO_KEY_PREFIX',
                value: '',
              },
            ],
            resources: {
              requests: {
                cpu: '20m',
                memory: '64Mi',
              },
              limits: {
                cpu: '80m',
                memory: '512Mi',
              },
            },
          },
        ],
      },
    },
  },
}
