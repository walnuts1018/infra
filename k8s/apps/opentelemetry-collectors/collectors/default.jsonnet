std.mergePatch((import '_base.libsonnet'), {
  metadata: {
    name: 'default',
  },
  spec: {
    mode: 'deployment',
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
              'otlphttp/vaxila',
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
              // 'otlphttp/prometheus',
              'prometheusremotewrite',
              // 'otlp/mackerel',
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
      maxReplicas: 10,
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
