local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local commonEnv = import '../env.libsonnet';
local s3Irsa = import '../s3-irsa.libsonnet';
local config = import 'configmap.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-martin',
    namespace: app.namespace,
    labels: labels(app.name + '-martin'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(app.name + '-martin'),
    },
    template: {
      metadata: {
        labels: labels(app.name + '-martin'),
      },
      spec: {
        serviceAccountName: (import '../sa.jsonnet').metadata.name,
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'martin',
            image: 'ghcr.io/maplibre/martin:1.14.0',
            imagePullPolicy: 'IfNotPresent',
            args: ['--config', '/config/config.yaml'],
            env: commonEnv + s3Irsa.env,
            ports: [
              { name: 'http', containerPort: 3000 },
            ],
            readinessProbe: {
              httpGet: { path: '/health', port: 3000 },
              initialDelaySeconds: 10,
              timeoutSeconds: 5,
              failureThreshold: 5,
            },
            livenessProbe: {
              httpGet: { path: '/health', port: 3000 },
              initialDelaySeconds: 30,
              timeoutSeconds: 5,
              failureThreshold: 5,
            },
            resources: {
              requests: { cpu: '50m', memory: '128Mi' },
              limits: { cpu: '1', memory: '512Mi' },
            },
            volumeMounts: [
              { name: 'config', mountPath: '/config', readOnly: true },
            ] + s3Irsa.volumeMounts,
          },
        ],
        volumes: [
          { name: 'config', configMap: { name: config.metadata.name } },
        ] + s3Irsa.volumes,
      },
    },
  },
}
