function(
  clusterName='kurumi',
) {
  apiVersion: 'opentelemetry.io/v1beta1',
  kind: 'OpenTelemetryCollector',
  spec: {
    managementState: 'managed',
    serviceAccount: (import '../sa.jsonnet').metadata.name,
    image: 'ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.140.1',
    config: {
      processors: {
        'resource/cluster_name': {
          attributes: [
            {
              key: 'k8s.cluster.name',
              action: 'upsert',
              value: clusterName,
            },
          ],
        },
      },
      exporters: {
        'otlphttp/prometheus': {
          endpoint: 'http://prometheus-stack-kube-prom-prometheus.monitoring.svc.clusterset.local:9090/api/v1/otlp',
          tls: {
            insecure: true,
          },
        },
        prometheusremotewrite: {
          endpoint: 'http://prometheus-stack-kube-prom-prometheus.monitoring.svc.clusterset.local:9090/api/v1/write',
          resource_to_telemetry_conversion: {
            enabled: true,
          },
        },
        'otlp/tempo': {
          endpoint: 'tempo.tempo.svc.clusterset.local:4317',
          tls: {
            insecure: true,
          },
        },
        'otlphttp/loki': {
          endpoint: 'http://loki-gateway.loki.svc.clusterset.local/otlp',
          tls: {
            insecure: true,
          },
        },
        'otlphttp/vaxila': {
          endpoint: 'https://otlp-vaxila.mackerelio.com',
          headers: {
            Accept: '*/*',
            'Mackerel-Api-Key': '${env:MACKEREL_APIKEY}',
          },
        },
        'otlp/mackerel': {
          endpoint: 'otlp.mackerelio.com:4317',
          compression: 'gzip',
          headers: {
            'Mackerel-Api-Key': '${env:MACKEREL_APIKEY}',
          },
        },
        file: {
          path: '/tmp/debug.json',
          format: 'json',
        },
        debug: {
          verbosity: 'detailed',
        },
      },
    },
    volumes: [
      {
        name: 'tmp',
        emptyDir: {},
      },
    ],
    volumeMounts: [
      {
        name: 'tmp',
        mountPath: '/tmp',
      },
    ],
  },
}
