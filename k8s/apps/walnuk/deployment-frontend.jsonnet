{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').appname.frontend,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').appname.frontend),
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')((import 'app.json5').appname.frontend),
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')((import 'app.json5').appname.frontend),
      },
      spec: {
        securityContext: {
          runAsUser: 10001,
        },
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'next',
            image: 'ghcr.io/walnuts1018/walnuk-frontend:v0.0.37',
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
                value: 'http://' + (import 'service-backend.jsonnet').metadata.name + '.' + (import 'app.json5').namespace + '.svc.cluster.local:8080',
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
              matchLabels: (import '../../components/labels.libsonnet')((import 'app.json5').appname.frontend),
            },
          },
        ],
      },
    },
  },
}
