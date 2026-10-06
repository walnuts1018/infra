function(
  clusterName='kurumi',
) {
  apiVersion: 'opentelemetry.io/v1beta1',
  kind: 'OpenTelemetryCollector',
  metadata: {
    name: 'default',
  },
  spec: {
    managementState: 'managed',
    image: 'ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.162.0@sha256:39923a8e431bd1f57be82411999d389fcfe40857492e4365456d97a4c1f74be6',
    serviceAccount: (import 'sa.jsonnet').metadata.name,
    mode: 'deployment',
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
        'transform/add_sample_key': {
          error_mode: 'ignore',
          log_statements: [
            'set(log.attributes["_sample_key"], UUID())',
          ],
        },
        'probabilistic_sampler/mackerel': {
          sampling_percentage: 1,
          mode: 'hash_seed',
          attribute_source: 'record',
          from_attribute: '_sample_key',
          hash_seed: 1018,
          fail_closed: true,
        },
        'transform/remove_sample_key': {
          error_mode: 'ignore',
          log_statements: [
            'delete_key(log.attributes, "_sample_key")',
          ],
        },
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
            'set(resource.attributes["user.id"], otelcol.client.metadata["x-picca-authenticated-user-id"]) where otelcol.client.metadata["x-picca-authenticated-user-id"] != nil',
            'set(resource.attributes["user.email"], otelcol.client.metadata["x-picca-authenticated-user-email"]) where otelcol.client.metadata["x-picca-authenticated-user-email"] != nil',
          ],
          metric_statements: [
            'delete_key(resource.attributes, "user.id")',
            'delete_key(resource.attributes, "user.email")',
            'delete_key(datapoint.attributes, "user.id")',
            'delete_key(datapoint.attributes, "user.email")',
            'delete_key(scope.attributes, "user.id")',
            'delete_key(scope.attributes, "user.email")',
            'set(resource.attributes["user.id"], otelcol.client.metadata["x-picca-authenticated-user-id"]) where otelcol.client.metadata["x-picca-authenticated-user-id"] != nil',
            'set(resource.attributes["user.email"], otelcol.client.metadata["x-picca-authenticated-user-email"]) where otelcol.client.metadata["x-picca-authenticated-user-email"] != nil',
          ],
          log_statements: [
            'delete_key(resource.attributes, "user.id")',
            'delete_key(resource.attributes, "user.email")',
            'delete_key(log.attributes, "user.id")',
            'delete_key(log.attributes, "user.email")',
            'delete_key(scope.attributes, "user.id")',
            'delete_key(scope.attributes, "user.email")',
            'set(resource.attributes["user.id"], otelcol.client.metadata["x-picca-authenticated-user-id"]) where otelcol.client.metadata["x-picca-authenticated-user-id"] != nil',
            'set(resource.attributes["user.email"], otelcol.client.metadata["x-picca-authenticated-user-email"]) where otelcol.client.metadata["x-picca-authenticated-user-email"] != nil',
          ],
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
          timeout: '5s',
          retry_on_failure: {
            enabled: true,
            initial_interval: '1s',
            max_interval: '30s',
            max_elapsed_time: '0s',
          },
          sending_queue: {
            enabled: true,
            num_consumers: 4,
            sizer: 'items',
            queue_size: 50000,
            block_on_overflow: true,
            wait_for_result: false,
            batch: {
              sizer: 'bytes',
              flush_timeout: '500ms',
              min_size: 524288,  // 512 KiB
              max_size: 1048576,  // 1 MiB
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
