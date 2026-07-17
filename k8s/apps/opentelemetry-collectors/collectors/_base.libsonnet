function(
  clusterName='kurumi',
) {
  apiVersion: 'opentelemetry.io/v1beta1',
  kind: 'OpenTelemetryCollector',
  spec: {
    managementState: 'managed',
    serviceAccount: (import '../sa.jsonnet').metadata.name,
    image: 'ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.156.0',
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
        'probabilistic_sampler/mackerel': {
          sampling_percentage: 5,
        },
      },
      exporters: {
        'otlp_grpc/tempo': {
          endpoint: 'tempo-gateway.tempo.svc.cluster.local:4317',
          tls: {
            insecure: true,
          },
          sending_queue: {
            batch: {
              flush_timeout: '10s',
              min_size: 5000,
              max_size: 5000,
            },
          },
        },
        'otlp_http/loki': {
          endpoint: 'http://loki-gateway.loki.svc.cluster.local/otlp',
          tls: {
            insecure: true,
          },
          sending_queue: {
            batch: {
              flush_timeout: '10s',
              min_size: 5000,
              max_size: 5000,
            },
          },
        },
        'otlp_http/mackerel': {
          endpoint: 'https://otlp-vaxila.mackerelio.com',
          headers: {
            Accept: '*/*',
            'Mackerel-Api-Key': '${env:MACKEREL_APIKEY}',
          },
          sending_queue: {
            batch: {
              flush_timeout: '10s',
              min_size: 5000,
              max_size: 5000,
            },
          },
        },
        'otlp_grpc/mackerel': {
          endpoint: 'otlp.mackerelio.com:4317',
          compression: 'gzip',
          headers: {
            'Mackerel-Api-Key': '${env:MACKEREL_APIKEY}',
          },
          sending_queue: {
            batch: {
              flush_timeout: '10s',
              min_size: 5000,
              max_size: 5000,
            },
          },
        },
        'prometheus_remote_write/victoriametrics': {
          endpoint: 'http://victoria-metrics-victoria-metrics-cluster-vminsert.victoria-metrics.svc.cluster.local:8480/insert/0/prometheus/api/v1/write',
          timeout: '30s',
          resource_to_telemetry_conversion: {
            enabled: true,
          },
        },
        'otlp_grpc/pyroscope': {
          endpoint: 'http://pyroscope.pyroscope.svc.cluster.local:4317',
          tls: {
            insecure: true,
          },
          sending_queue: {
            batch: {
              flush_timeout: '10s',
              min_size: 5000,
              max_size: 5000,
            },
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
