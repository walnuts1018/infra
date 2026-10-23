local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(app.name),
    },
    template: {
      metadata: {
        labels: labels(app.name),
      },
      spec: {
        automountServiceAccountToken: false,
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 101,
          runAsGroup: 101,
          fsGroup: 101,
          seccompProfile: {
            type: 'RuntimeDefault',
          },
        },
        containers: [
          {
            name: 'website',
            image: 'ghcr.io/manifest-configuration-language/website:main@sha256:82c755d0f4673874189e0e43972fc1694be079ca4db9bca8b58ff868cf122b48',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                name: 'http',
                containerPort: 8080,
              },
            ],
            readinessProbe: {
              httpGet: {
                path: '/',
                port: 'http',
              },
            },
            livenessProbe: {
              httpGet: {
                path: '/',
                port: 'http',
              },
            },
            resources: {
              requests: {
                cpu: '10m',
                memory: '32Mi',
              },
              limits: {
                memory: '128Mi',
              },
            },
            securityContext: {
              allowPrivilegeEscalation: false,
              readOnlyRootFilesystem: true,
              capabilities: {
                drop: ['ALL'],
              },
            },
            volumeMounts: [
              { name: 'nginx-cache', mountPath: '/var/cache/nginx' },
              { name: 'nginx-run', mountPath: '/var/run' },
              { name: 'nginx-tmp', mountPath: '/tmp' },
            ],
          },
        ],
        volumes: [
          { name: 'nginx-cache', emptyDir: {} },
          { name: 'nginx-run', emptyDir: {} },
          { name: 'nginx-tmp', emptyDir: {} },
        ],
      },
    },
  },
}
