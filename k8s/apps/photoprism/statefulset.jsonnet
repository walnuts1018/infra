{
  apiVersion: 'apps/v1',
  kind: 'StatefulSet',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    selector: {
      matchLabels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    },
    serviceName: (import 'service.jsonnet').metadata.name,
    replicas: 1,
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
      },
      spec: {
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'photoprism',
            image: 'photoprism/photoprism:250224',
            resources: {
              requests: {
                cpu: '0',
                memory: '2Gi',
              },
              limits: {
                cpu: '2',
                memory: '4Gi',
              },
            },
            env: [
              {
                name: 'PHOTOPRISM_ORIGINALS_LIMIT',
                value: '-1',
              },
              {
                name: 'PHOTOPRISM_DETECT_NSFW',
                value: 'true',
              },
              {
                name: 'PHOTOPRISM_DATABASE_DRIVER',
                value: 'mysql',
              },
              {
                name: 'PHOTOPRISM_HTTP_HOST',
                value: '0.0.0.0',
              },
              {
                name: 'PHOTOPRISM_HTTP_PORT',
                value: '2342',
              },
              {
                name: 'PHOTOPRISM_ADMIN_USER',
                value: 'photoprism',
              },
              {
                name: 'PHOTOPRISM_SITE_URL',
                value: 'https://photoprism.walnuts.dev/',
              },
              {
                name: 'PHOTOPRISM_DISABLE_TLS',
                value: 'true',
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/health',
                port: 2342,
              },
              failureThreshold: 1,
              initialDelaySeconds: 10,
              periodSeconds: 10,
            },
            envFrom: [
              {
                secretRef: {
                  name: (import 'external-secret.jsonnet').spec.target.name,
                  optional: false,
                },
              },
            ],
            ports: [
              {
                containerPort: 2342,
                name: 'http',
              },
            ],
            volumeMounts: [
              {
                mountPath: '/photoprism/originals',
                name: 'originals',
              },
              {
                mountPath: '/photoprism/import',
                name: 'import',
              },
              {
                mountPath: '/photoprism/storage',
                name: 'storage',
              },
              {
                mountPath: '/photoprism/storage/cache',
                name: 'cache',
              },
              {
                mountPath: '/tmp',
                name: 'tmp',
              },
              {
                mountPath: '/run',
                name: 'run',
              },
            ],
            readinessProbe: {
              httpGet: {
                path: '/api/v1/status',
                port: 'http',
              },
            },
          },
        ],
        volumes: [
          {
            name: 'originals',
            hostPath: {
              path: '/mnt/data/share/CameraRoll',
              type: 'Directory',
            },
          },
          {
            name: 'import',
            persistentVolumeClaim: {
              claimName: 'photoprism-import',
            },
          },
          {
            name: 'cache',
            persistentVolumeClaim: {
              claimName: 'photoprism-cache',
            },
          },
          {
            name: 'storage',
            persistentVolumeClaim: {
              claimName: 'photoprism-storage',
            },
          },
          {
            name: 'tmp',
            emptyDir: {},
          },
          {
            name: 'run',
            emptyDir: {},
          },
        ],
        nodeSelector: {
          'kubernetes.io/hostname': 'cake',
        },
      },
    },
  },
}
