local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local pvc = import 'pvc.jsonnet';
local serviceAccount = import 'service-account.jsonnet';
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
        serviceAccountName: serviceAccount.metadata.name,
        securityContext: {
          fsGroup: 1000,
          runAsGroup: 1000,
          runAsUser: 1000,
        },
        containers: [
          {
            name: 'shumoku',
            securityContext: {
              allowPrivilegeEscalation: false,
              capabilities: {
                drop: ['ALL'],
              },
              readOnlyRootFilesystem: false,
              runAsNonRoot: true,
            },
            image: 'ghcr.io/konoe-akitoshi/shumoku:0.1.5-beta.5',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                name: 'http',
                containerPort: 8080,
                protocol: 'TCP',
              },
            ],
            env: [
              {
                name: 'PORT',
                value: '8080',
              },
              {
                name: 'HOST',
                value: '0.0.0.0',
              },
              {
                name: 'DATA_DIR',
                value: '/data',
              },
              {
                name: 'SHUMOKU_DEPLOYMENT',
                value: 'kubernetes',
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/api/health',
                port: 'http',
              },
              initialDelaySeconds: 5,
              periodSeconds: 30,
              timeoutSeconds: 3,
              failureThreshold: 3,
            },
            readinessProbe: {
              httpGet: {
                path: '/api/health',
                port: 'http',
              },
              initialDelaySeconds: 5,
              periodSeconds: 10,
              timeoutSeconds: 3,
              failureThreshold: 3,
            },
            resources: {},
            volumeMounts: [
              {
                name: 'data',
                mountPath: '/data',
              },
              {
                name: 'tmp',
                mountPath: '/tmp',
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'data',
            persistentVolumeClaim: {
              claimName: pvc.metadata.name,
            },
          },
          {
            name: 'tmp',
            emptyDir: {},
          },
        ],
      },
    },
  },
}
