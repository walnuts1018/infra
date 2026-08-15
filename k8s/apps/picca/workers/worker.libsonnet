local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local commonEnv = import '../env.libsonnet';
local externalSecret = import '../external-secret.jsonnet';
local s3Irsa = import '../s3-irsa.libsonnet';
local scyllaTls = import '../scylla-tls.libsonnet';

function(name, image) {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-' + name,
    namespace: app.namespace,
    labels: (labels)(app.name + '-' + name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (labels)(app.name + '-' + name),
    },
    template: {
      metadata: {
        labels: (labels)(app.name + '-' + name),
      },
      spec: {
        serviceAccountName: (import '../sa.jsonnet').metadata.name,
        imagePullSecrets: [
          { name: 'ghcr-login-secret' },
        ],
        containers: [
          (import '../../../components/container.libsonnet') {
            name: name,
            image: image,
            imagePullPolicy: 'IfNotPresent',
            envFrom: [
              { secretRef: { name: externalSecret.spec.target.name } },
            ],
            env: commonEnv + s3Irsa.env + scyllaTls.env + [
              { name: 'OTEL_SERVICE_NAME', value: 'picca-' + name },
            ],
            resources: {
              requests: { cpu: '20m', memory: '64Mi' },
              limits: { cpu: '500m', memory: '512Mi' },
            },
            volumeMounts: [
              { name: 'tmp', mountPath: '/tmp' },
              s3Irsa.volumeMount,
            ] + scyllaTls.volumeMounts,
          },
        ],
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 65532,
          runAsGroup: 65532,
        },
        volumes: [
          { name: 'tmp', emptyDir: {} },
          s3Irsa.volume,
        ] + scyllaTls.volumes,
      },
    },
  },
}
