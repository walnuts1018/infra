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
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
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
            image: 'ghcr.io/manifest-configuration-language/website:main@sha256:a6b543d0d4d74147b81d079179c39bdd76afdf482d30164de8fddad6e324067d',
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
              { name: 'tmp', mountPath: '/tmp' },
            ],
          },
        ],
        volumes: [
          { name: 'tmp', emptyDir: {} },
        ],
      },
    },
  },
}
