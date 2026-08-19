local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local commonEnv = import '../env.libsonnet';
local externalSecret = import '../external-secret.jsonnet';
local plans = import '../plans.libsonnet';
local s3Irsa = import '../s3-irsa.libsonnet';
local scyllaTls = import '../scylla-tls.libsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-apiserver',
    namespace: app.namespace,
    labels: labels(app.name + '-apiserver'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(app.name + '-apiserver'),
    },
    template: {
      metadata: {
        labels: labels(app.name + '-apiserver'),
      },
      spec: {
        serviceAccountName: (import '../sa.jsonnet').metadata.name,
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        initContainers: [
          (import '../../../components/container.libsonnet') {
            name: 'migrations',
            image: 'ghcr.io/walnuts1018/picca/migrations:v0.0.13',
            imagePullPolicy: 'IfNotPresent',
            envFrom: [
              {
                secretRef: {
                  name: externalSecret.spec.target.name,
                },
              },
            ],
            env: commonEnv + s3Irsa.env + scyllaTls.env + [
              {
                name: 'OTEL_SERVICE_NAME',
                value: 'picca-apiserver',
              },
            ],
            volumeMounts: s3Irsa.volumeMounts + scyllaTls.volumeMounts,
          },
        ],
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'apiserver',
            image: 'ghcr.io/walnuts1018/picca/apiserver:v0.0.13',
            imagePullPolicy: 'IfNotPresent',
            envFrom: [
              {
                secretRef: {
                  name: externalSecret.spec.target.name,
                },
              },
            ],
            env: commonEnv + s3Irsa.env + scyllaTls.env + plans.env + [
              {
                name: 'OTEL_SERVICE_NAME',
                value: 'picca-apiserver',
              },
            ],
            ports: [
              {
                containerPort: 8080,
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/livez',
                port: 8080,
              },
              initialDelaySeconds: 10,
              failureThreshold: 5,
            },
            readinessProbe: {
              httpGet: {
                path: '/readyz',
                port: 8080,
              },
              initialDelaySeconds: 10,
              failureThreshold: 5,
            },
            resources: {
              requests: {
                cpu: '50m',
                memory: '128Mi',
              },
              limits: {
                cpu: '500m',
                memory: '512Mi',
              },
            },
            volumeMounts: [
              { name: 'tmp', mountPath: '/tmp' },
            ] + s3Irsa.volumeMounts + scyllaTls.volumeMounts + plans.volumeMounts,
          },
        ],
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 65532,
          runAsGroup: 65532,
        },
        volumes: [
          { name: 'tmp', emptyDir: {} },
        ] + s3Irsa.volumes + scyllaTls.volumes + plans.volumes,
      },
    },
  },
}
