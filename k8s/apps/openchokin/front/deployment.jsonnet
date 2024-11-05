{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import '../app.json5').name + '-front',
    namespace: (import '../app.json5').namespace,
    labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-front' },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-front' },
    },
    template: {
      metadata: {
        labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-front' },
      },
      spec: {
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'openchokin-front',
            image: 'ghcr.io/walnuts1018/openchokin-front:v0.0.0-805921b42b330190ff496e2d810ec3846947162a-66',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 3000,
              },
            ],
            resources: {
              requests: {
                memory: '100Mi',
              },
              limits: {},
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
                    name: (import '../external-secret.jsonnet').spec.target.name,
                    key: 'zitade-client-id',
                  },
                },
              },
              {
                name: 'ZITADEL_CLIENT_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: (import '../external-secret.jsonnet').spec.target.name,
                    key: 'zitadel-client-secret',
                  },
                },
              },
              {
                name: 'NEXTAUTH_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: (import '../external-secret.jsonnet').spec.target.name,
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
                    name: (import '../external-secret.jsonnet').spec.target.name,
                    key: 'redis-password',
                  },
                },
              },
              {
                name: 'CACHE_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: (import '../external-secret.jsonnet').spec.target.name,
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
