std.mergePatch((import '_base.libsonnet'), {
  metadata: {
    name: 'prometheus-exporter',
  },
  spec: {
    mode: 'deployment',
    image: 'otel/opentelemetry-collector-contrib',
    config: {
      receivers: {
        otlp: {
          protocols: {
            grpc: {
              max_recv_msg_size_mib: 100,
            },
            http: {},
          },
        },
      },
      processors: {
        memory_limiter: {
          check_interval: '5s',
          limit_mib: 2000,
          spike_limit_percentage: 15,
        },
        batch: {
          send_batch_size: 10000,
          timeout: '10s',
        },
      },
      exporters: {
        prometheusremotewrite: {
          endpoint: 'http://prometheus-stack-kube-prom-prometheus.monitoring.svc.cluster.local:9090/api/v1/write',
          resource_to_telemetry_conversion: {
            enabled: true,
          },
        },
      },
      service: {
        pipelines: {
          metrics: {
            receivers: [
              'otlp',
            ],
            processors: [
              'memory_limiter',
              'batch',
            ],
            exporters: [
              'prometheusremotewrite',
            ],
          },
        },
      },
    },
    resources: {
      requests: {
        memory: '200Mi',
      },
    },
    autoscaler: {
      minReplicas: 1,
      maxReplicas: 5,
      metrics: [
        {
          type: 'Resource',
          resource: {
            name: 'cpu',
            target: {
              type: 'Utilization',
              averageUtilization: 100,
            },
          },
        },
        {
          type: 'Resource',
          resource: {
            name: 'memory',
            target: {
              type: 'Utilization',
              averageUtilization: 100,
            },
          },
        },
      ],
    },
  },
})
