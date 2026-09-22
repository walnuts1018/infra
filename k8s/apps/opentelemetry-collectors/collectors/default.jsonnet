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
            http: {
              include_metadata: true,
            },
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
        'transform/picca_identity': {
          error_mode: 'ignore',
          trace_statements: [
            'delete_key(resource.attributes, "user.id")',
            'delete_key(resource.attributes, "user.email")',
            'delete_key(span.attributes, "user.id")',
            'delete_key(span.attributes, "user.email")',
            'delete_key(scope.attributes, "user.id")',
            'delete_key(scope.attributes, "user.email")',
            'set(resource.attributes["user.id"], metadata["x-picca-authenticated-user-id"])',
            'set(resource.attributes["user.email"], metadata["x-picca-authenticated-user-email"])',
          ],
          metric_statements: [
            'delete_key(resource.attributes, "user.id")',
            'delete_key(resource.attributes, "user.email")',
            'delete_key(metric.attributes, "user.id")',
            'delete_key(metric.attributes, "user.email")',
            'delete_key(scope.attributes, "user.id")',
            'delete_key(scope.attributes, "user.email")',
            'set(resource.attributes["user.id"], metadata["x-picca-authenticated-user-id"])',
            'set(resource.attributes["user.email"], metadata["x-picca-authenticated-user-email"])',
          ],
          log_statements: [
            'delete_key(resource.attributes, "user.id")',
            'delete_key(resource.attributes, "user.email")',
            'delete_key(log.attributes, "user.id")',
            'delete_key(log.attributes, "user.email")',
            'delete_key(scope.attributes, "user.id")',
            'delete_key(scope.attributes, "user.email")',
            'set(resource.attributes["user.id"], metadata["x-picca-authenticated-user-id"])',
            'set(resource.attributes["user.email"], metadata["x-picca-authenticated-user-email"])',
          ],
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
              'transform/picca_identity',
              'resource/cluster_name',
            ],
            exporters: [
              'otlp_grpc/tempo',
              'span_metrics',
              // 'otlp_http/mackerel',
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
              'transform/picca_identity',
              'resource/cluster_name',
            ],
            exporters: [
              // 'otlp_http/prometheus',
              // 'otlp_grpc/mackerel',
              'prometheus_remote_write/victoriametrics',
            ],
          },
          logs: {
            receivers: [
              'otlp',
            ],
            processors: [
              'memory_limiter',
              'k8s_attributes',
              'transform/picca_identity',
              'resource/cluster_name',
            ],
            exporters: [
              'otlp_http/loki',
            ],
          },
          'logs/mackerel': {
            receivers: [
              'otlp',
            ],
            processors: [
              'memory_limiter',
              'k8s_attributes',
              'transform/picca_identity',
              'resource/cluster_name',
              'probabilistic_sampler/mackerel',
            ],
            exporters: [
              'otlp_http/mackerel',
            ],
          },
        },
      },
    },
    autoscaler: {
      minReplicas: 1,
      maxReplicas: 5,
      targetMemoryUtilization: 100,
    },
    resources: {
      requests: {
        cpu: '4m',
        memory: '156Mi',
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
