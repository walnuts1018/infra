local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local s3Irsa = import '../s3-irsa.libsonnet';
local externalSecret = import 'external-secret.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-imgproxy',
    namespace: app.namespace,
    labels: labels(app.name + '-imgproxy'),
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: labels(app.name + '-imgproxy'),
    },
    template: {
      metadata: {
        labels: labels(app.name + '-imgproxy'),
      },
      spec: {
        serviceAccountName: (import '../sa.jsonnet').metadata.name,
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'imgproxy',
            image: 'ghcr.io/imgproxy/imgproxy:v3.31.4',
            imagePullPolicy: 'IfNotPresent',
            envFrom: [
              {
                secretRef: {
                  name: externalSecret.spec.target.name,
                },
              },
            ],
            env: s3Irsa.env,
            ports: [
              {
                name: 'http',
                containerPort: 8080,
              },
              {
                name: 'metrics',
                containerPort: 8081,
              },
            ],
            readinessProbe: {
              httpGet: {
                path: '/health',
                port: 8080,
              },
              initialDelaySeconds: 10,
              timeoutSeconds: 5,
              failureThreshold: 5,
            },
            livenessProbe: {
              httpGet: {
                path: '/health',
                port: 8080,
              },
              initialDelaySeconds: 30,
              timeoutSeconds: 5,
              failureThreshold: 5,
            },
            resources: {
              requests: {
                cpu: '50m',
                memory: '128Mi',
              },
              limits: {
                cpu: '1',
                memory: '512Mi',
              },
            },
            volumeMounts: s3Irsa.volumeMounts,
          },
        ],
        volumes: s3Irsa.volumes,
      },
    },
  },
}
