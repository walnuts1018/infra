std.mergePatch((import '_base.libsonnet'), {
  metadata: {
    name: 'default',
  },
  spec: {
    mode: 'deployment',
    config: {
      connectors: {
        spanmetrics: {
          histogram: {
            explicit: {
              buckets: [
                '1ms',
                '10ms',
                '100ms',
                '200ms',
                '400ms',
                '800ms',
                '1s',
              ],
            },
          },
          dimensions: [
            {
              name: 'http.method',
              default: 'GET',
            },
            {
              name: 'http.host',
            },
            {
              name: 'http.path',
            },
            {
              name: 'http.target',
            },
            {
              name: 'http.status_code',
            },
          ],
          metrics_flush_interval: '15s',
        },
      },
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
        k8sattributes: {
          auth_type: 'serviceAccount',
          extract: {
            metadata: [
              'k8s.cluster.uid',
            ],
          },
        },
        batch: {
          send_batch_size: 5000,
          send_batch_max_size: 5000,
          timeout: '10s',
        },
      },
      exporters: {
        'otlphttp/prometheus': {
          endpoint: 'http://prometheus-stack-kube-prom-prometheus.monitoring.svc.cluster.local:9090/api/v1/otlp',
          tls: {
            insecure: true,
          },
        },
        'otlp/prometheus-exporter': {
          endpoint: 'prometheus-exporter-collector.opentelemetry-collector.svc.cluster.local:4317',
          tls: {
            insecure: true,
          },
        },
        'otlp/tempo': {
          endpoint: 'tempo.monitoring.svc.cluster.local:4317',
          tls: {
            insecure: true,
          },
        },
        'otlphttp/loki': {
          endpoint: 'http://loki-gateway.loki.svc.cluster.local/otlp',
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
      },
      service: {
        pipelines: {
          traces: {
            receivers: [
              'otlp',
            ],
            processors: [
              'memory_limiter',
              'batch',
              'k8sattributes',
            ],
            exporters: [
              'otlp/tempo',
              'spanmetrics',
              // 'otlphttp/vaxila',
            ],
          },
          metrics: {
            receivers: [
              'otlp',
              'spanmetrics',
            ],
            processors: [
              'memory_limiter',
              'batch',
              'k8sattributes',
            ],
            exporters: [
              'otlphttp/prometheus',
              'otlp/prometheus-exporter',
              'otlp/mackerel',
            ],
          },
          logs: {
            receivers: [
              'otlp',
            ],
            processors: [
              'memory_limiter',
              'batch',
              'k8sattributes',
            ],
            exporters: [
              'otlphttp/loki',
            ],
          },
        },
      },
    },
    autoscaler: {
      minReplicas: 1,
      maxReplicas: 5,
      targetCPUUtilization: 100,
      targetMemoryUtilization: 100,
    },
    resources: {
      requests: {
        cpu: '20m',
        memory: '100Mi',
      },
    },
    env: [
      {
        name: 'K8S_NODE_IP',
        valueFrom: {
          fieldRef: {
            fieldPath: 'status.hostIP',
          },
        },
      },
      {
        name: 'K8S_NODE_NAME',
        valueFrom: {
          fieldRef: {
            fieldPath: 'spec.nodeName',
          },
        },
      },
      {
        name: 'MACKEREL_APIKEY',
        valueFrom: {
          secretKeyRef: {
            name: (import '../external-secret.jsonnet').spec.target.name,
            key: 'mackerel-api-key',
          },
        },
      },
    ],
  },
})
