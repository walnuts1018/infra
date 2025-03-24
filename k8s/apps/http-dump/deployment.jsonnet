{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
      },
      spec: {
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'http-dump',
            image: 'ghcr.io/walnuts1018/http-dump:5f3e34da7c2f7ac88e34a3cf72de0e4c1872a8b4-43',
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
      },
    },
  },
}
