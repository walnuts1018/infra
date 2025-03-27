std.mergePatch((import '_base.libsonnet'), {
  metadata: {
    name: 'k8s-deployment',
  },
  spec: {
    replicas: 1,
    mode: 'deployment',
    image: 'otel/opentelemetry-collector-k8s:0.122.1',
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
        },
      },
    },
    resources: {
      requests: {
        cpu: '6m',
        memory: '90Mi',
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
