local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local externalSecret = import 'external-secret.jsonnet';
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
          runAsUser: 65532,
          runAsGroup: 65532,
          seccompProfile: {
            type: 'RuntimeDefault',
          },
        },
        containers: [
          {
            name: 'api',
            image: 'ghcr.io/manifest-configuration-language/mcl-playground-api:main@sha256:dd342c8ed76d04da1bd0d4f62bec8c7ccdafb3e7a24e446ca83a35f49b68c262',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                name: 'http',
                containerPort: 8080,
              },
            ],
            env: [
              {
                name: 'LISTEN_ADDR',
                value: ':8080',
              },
              {
                name: 'DATABASE_URL',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'DATABASE_URL',
                  },
                },
              },
            ],
            readinessProbe: {
              httpGet: {
                path: '/readyz',
                port: 'http',
              },
              periodSeconds: 10,
              timeoutSeconds: 2,
            },
            livenessProbe: {
              httpGet: {
                path: '/healthz',
                port: 'http',
              },
              periodSeconds: 20,
              timeoutSeconds: 2,
            },
            resources: {
              requests: {
                cpu: '10m',
                memory: '64Mi',
              },
              limits: {
                memory: '384Mi',
              },
            },
            securityContext: {
              allowPrivilegeEscalation: false,
              readOnlyRootFilesystem: true,
              capabilities: {
                drop: ['ALL'],
              },
            },
          },
        ],
      },
    },
  },
}
