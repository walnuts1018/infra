std.mergePatch((import '_base.libsonnet'), {
  metadata: {
    name: 'servicemonitor',
  },
  spec: {
    replicas: 1,
    mode: 'statefulset',
    targetAllocator: {
      enabled: true,
      serviceAccount: (import '../sa.jsonnet').metadata.name,
      prometheusCR: {
        enabled: true,
        serviceMonitorSelector: {
          matchExpressions: [
            {
              key: 'walnuts.dev/scraped-by',
              operator: 'NotIn',
              values: [
                'prometheus',
              ],
            },
          ],
        },
      },
    },
    config: {
      receivers: {
        prometheus: {
          config: {
            scrape_configs: [
              {
                job_name: 'otel-collector',
                scrape_interval: '30s',
                static_configs: [
                  {
                    targets: [
                      '0.0.0.0:8888',
                    ],
                  },
                ],
              },
            ],
          },
        },
      },
      processors: {
        memory_limiter: {
          check_interval: '1s',
          limit_percentage: 75,
          spike_limit_percentage: 15,
        },
        batch: {
          send_batch_size: 10000,
          timeout: '10s',
        },
      },
      exporters: {
        'otlp/default': {
          endpoint: 'default-collector.opentelemetry-collector.svc.cluster.local:4317',
          tls: {
            insecure: true,
          },
        },
      },
      service: {
        pipelines: {
          metrics: {
            receivers: [
              'prometheus',
            ],
            processors: [
              'memory_limiter',
              'batch',
            ],
            exporters: [
              'otlp/default',
            ],
          },
        },
      },
    },
  },
})
