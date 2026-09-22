function(app)
  local labels = import '../../../labels.libsonnet';
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: app.name + '-frontend',
      namespace: app.namespace,
      labels: labels(app.name + '-frontend'),
    },
    spec: {
      replicas: 1,
      selector: {
        matchLabels: labels(app.name + '-frontend'),
      },
      template: {
        metadata: {
          labels: labels(app.name + '-frontend'),
        },
        spec: {
          imagePullSecrets: [
            { name: 'ghcr-login-secret' },
          ],
          containers: [
            (import '../../../container.libsonnet') {
              name: 'frontend',
              image: 'ghcr.io/walnuts1018/picca/frontend:v0.0.96@sha256:31022284d4b6fc175b3a5598be2235ffdafba90a78206608371389cf2aa731a8',
              imagePullPolicy: 'IfNotPresent',
              env: [
                {
                  name: 'PICCA_API_URL',
                  value: 'http://picca-apiserver.picca.svc.cluster.local:8080',
                },
                {
                  name: 'PICCA_GRAPHQL_ENDPOINT',
                  value: 'https://picca.walnuts.dev/query',
                },
                {
                  name: 'PICCA_S3_EXTERNAL_ENDPOINT',
                  value: 'https://picca.seaweedfs.walnuts.dev',
                },
                {
                  name: 'PICCA_IMGPROXY_PUBLIC_URL',
                  value: 'https://imgproxy-picca.walnuts.dev',
                },
                {
                  name: 'PICCA_MAPS_URL',
                  value: 'https://maps.walnuts.dev',
                },
                {
                  name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
                  value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4318',
                },
                {
                  name: 'OTEL_SERVICE_NAME',
                  value: 'picca-frontend',
                },
              ],
              ports: [
                { containerPort: 3000 },
              ],
              livenessProbe: {
                httpGet: {
                  path: '/api/health',
                  port: 3000,
                },
                initialDelaySeconds: 15,
                failureThreshold: 5,
              },
              readinessProbe: {
                httpGet: {
                  path: '/api/health',
                  port: 3000,
                },
                initialDelaySeconds: 15,
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
                {
                  name: 'tmp',
                  mountPath: '/tmp',
                },
                {
                  name: 'cache',
                  mountPath: '/.cache',
                },
              ],
            },
          ],
          securityContext: {
            fsGroup: 65534,
            runAsGroup: 65534,
            runAsUser: 10001,
          },
          volumes: [
            {
              name: 'tmp',
              emptyDir: {},
            },
            {
              name: 'cache',
              emptyDir: {},
            },
          ],
        },
      },
    },
  }
