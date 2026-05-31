function(
  clusterName='kurumi',
) std.mergePatch((import '_base.libsonnet')(
  clusterName,
), {
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
        k8s_attributes: {
          auth_type: 'serviceAccount',
          extract: {
            metadata: [
              'k8s.cluster.uid',
            ],
          },
        },
      },
      connectors: {
        span_metrics: {
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
              'k8s_attributes',
              'resource/cluster_name',
            ],
            exporters: [
              'otlp_grpc/tempo',
              'span_metrics',
              // 'otlp_http/vaxila',
            ],
          },
          metrics: {
            receivers: [
              'otlp',
              'span_metrics',
            ],
            processors: [
              'memory_limiter',
              'k8s_attributes',
              'resource/cluster_name',
            ],
            exporters: [
              // 'otlp_http/prometheus',
              // 'otlp_grpc/mackerel',
              'prometheusremotewrite/victoriametrics',
            ],
          },
          logs: {
            receivers: [
              'otlp',
            ],
            processors: [
              'memory_limiter',
              'k8s_attributes',
              'resource/cluster_name',
            ],
            exporters: [
              'otlp_http/loki',
            ],
          },
        },
      },
    },
    autoscaler: {
      minReplicas: 1,
      maxReplicas: 10,
      targetMemoryUtilization: 100,
    },
    resources: {
      requests: {
        cpu: '5m',
        memory: '256Mi',
      },
      limits: {
        cpu: '1',
        memory: '2Gi',
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
