std.mergePatch((import '_base.libsonnet'), {
  metadata: {
    name: 'k8s-deployment',
  },
  spec: {
    replicas: 1,
    mode: 'deployment',
    image: 'otel/opentelemetry-collector-k8s',
    config: {
      receivers: {
        k8s_cluster: {
          auth_type: 'serviceAccount',
          node_conditions_to_report: [
            'Ready',
            'MemoryPressure',
          ],
          allocatable_types_to_report: [
            'cpu',
            'memory',
          ],
          resource_attributes: {
            'k8s.container.status.last_terminated_reason': {
              enabled: true,
            },
            'k8s.deployment.name': {
              enabled: true,
            },
          },
        },
        k8sobjects: {
          auth_type: 'serviceAccount',
          objects: [
            {
              name: 'pods',
              mode: 'pull',
              interval: '15m',
            },
            {
              name: 'events',
              mode: 'watch',
              group: 'events.k8s.io',
            },
          ],
        },
      },
      processors: {
        memory_limiter: {
          check_interval: '1s',
          limit_mib: 2000,
          spike_limit_percentage: 15,
        },
        batch: {
          send_batch_size: 10000,
          timeout: '10s',
        },
        k8sattributes: {
          auth_type: 'serviceAccount',
          extract: {
            metadata: [
              'k8s.cluster.uid',
            ],
          },
          pod_association: [
            {
              sources: [
                {
                  from: 'resource_attribute',
                  name: 'k8s.pod.ip',
                },
              ],
            },
            {
              sources: [
                {
                  from: 'resource_attribute',
                  name: 'k8s.pod.uid',
                },
              ],
            },
            {
              sources: [
                {
                  from: 'connection',
                },
              ],
            },
          ],
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
              'k8s_cluster',
            ],
            processors: [
              'memory_limiter',
              'batch',
              'k8sattributes',
            ],
            exporters: [
              'otlp/default',
            ],
          },
          logs: {
            receivers: [
              'k8sobjects',
            ],
            processors: [
              'memory_limiter',
              'batch',
              'k8sattributes',
            ],
            exporters: [
              'otlp/default',
            ],
          },
        },
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
    ],
  },
})
