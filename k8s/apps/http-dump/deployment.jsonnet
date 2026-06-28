local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (labels)(app.name),
    },
    template: {
      metadata: {
        labels: (labels)(app.name),
      },
      spec: {
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'http-dump',
            image: 'ghcr.io/walnuts1018/http-dump:2940b4a2f1f5f4fdfd6c41e6dd2d8c456837f3e1-46',
            ports: [
              {
                name: 'http',
                containerPort: 8080,
              },
            ],
            resources: {
              limits: {
                cpu: '500m',
                memory: '500Mi',
              },
              requests: {
                cpu: '0',
                memory: '10Mi',
              },
            },
            env: [
              {
                name: 'OTEL_EXPORTER_OTLP_INSECURE',
                value: 'true',
              },
              {
                name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
                value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4317',
              },
            ],
          },
        ],
        tolerations: [
          {
            key: 'node.walnuts.dev/low-performance',
            operator: 'Exists',
          },
        ],
      },
    },
  },
}
