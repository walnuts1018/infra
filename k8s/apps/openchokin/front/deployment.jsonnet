local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local externalSecret = import '../external-secret.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-front',
    namespace: app.namespace,
    labels: (labels)(app.name + '-front'),
  },
  spec: {
    selector: {
      matchLabels: (labels)(app.name + '-front'),
    },
    template: {
      metadata: {
        labels: (labels)(app.name + '-front'),
      },
      spec: {
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'openchokin-front',
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
            image: 'ghcr.io/walnuts1018/openchokin-front:v0.0.0-805921b42b330190ff496e2d810ec3846947162a-66',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 3000,
              },
            ],
            resources: {
              requests: {
                cpu: '100m',
                memory: '256Mi',
              },
              limits: {
                cpu: '500m',
                memory: '512Mi',
              },
            },
            env: [
              {
                name: 'ZITADEL_URL',
                value: 'https://auth.walnuts.dev',
              },
              {
                name: 'NEXTAUTH_URL',
                value: 'https://openchokin.walnuts.dev',
              },
              {
                name: 'ZITADEL_CLIENT_ID',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'zitade-client-id',
                  },
                },
              },
              {
                name: 'ZITADEL_CLIENT_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'zitadel-client-secret',
                  },
                },
              },
              {
                name: 'NEXTAUTH_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'nextauth-secret',
                  },
                },
              },
              {
                name: 'REDIS_SENTINEL_HOST',
                value: 'openchokin-front-redis-sentinel',
              },
              {
                name: 'REDIS_SENTINEL_PORT',
                value: '26379',
              },
              {
                name: 'REDIS_SENTINEL_NAME',
                value: 'mymaster',
              },
              {
                name: 'REDIS_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'redis-password',
                  },
                },
              },
              {
                name: 'CACHE_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'cache-password',
                  },
                },
              },
            ],
          },
        ],
      },
    },
  },
}
