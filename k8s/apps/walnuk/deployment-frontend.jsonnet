local container = import '../../components/container.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local serviceBackend = import 'service-backend.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.appname.frontend,
    namespace: app.namespace,
    labels: (labels)(app.appname.frontend),
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: (labels)(app.appname.frontend),
    },
    template: {
      metadata: {
        labels: (labels)(app.appname.frontend),
      },
      spec: {
        securityContext: {
          runAsUser: 10001,
          runAsGroup: 65534,
        },
        containers: [
          std.mergePatch((container) {
            name: 'next',
            image: 'ghcr.io/walnuts1018/walnuk-frontend:v0.0.157',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 3000,
              },
            ],
            resources: {
              requests: {
                cpu: '10m',
                memory: '128Mi',
              },
              limits: {
                cpu: '500m',
                memory: '512Mi',
              },
            },
            env: [
              {
                name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
                value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4317',
              },
              {
                name: 'API_ENDPOINT',
                value: 'http://' + serviceBackend.metadata.name + '.' + app.namespace + '.svc.cluster.local:8080',
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/',
                port: 3000,
              },
            },
            volumeMounts: [
              {
                name: 'next-cache',
                mountPath: '/app/.next/cache',
              },
            ],
          }, {
            securityContext: {
              runAsNonRoot: true,
              allowPrivilegeEscalation: false,
            },
          }),
        ],
        priorityClassName: 'high',
        volumes: [
          {
            name: 'next-cache',
            emptyDir: {},
          },
        ],
        topologySpreadConstraints: [
          {
            maxSkew: 1,
            topologyKey: 'kubernetes.io/hostname',
            whenUnsatisfiable: 'ScheduleAnyway',
            labelSelector: {
              matchLabels: (labels)(app.appname.frontend),
            },
          },
        ],
      },
    },
  },
}
