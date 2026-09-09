function(
  clusterName='kurumi',
) std.mergePatch((import '_base.libsonnet')(
  clusterName,
), {
  metadata: {
    name: 'atomic',
  },
  spec: {
    replicas: 1,
    mode: 'statefulset',
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
          metrics: {
            'k8s.container.status.reason': {
              enabled: true,
            },
            'k8s.container.status.state': {
              enabled: true,
            },
            'k8s.node.condition': {
              enabled: true,
            },
            'k8s.pod.status_reason': {
              enabled: true,
            },
          },
        },
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
        k8s_events: {
          auth_type: 'serviceAccount',
          namespaces: [],  // watch all namespaces
        },
      },
      processors: {
        memory_limiter: {
          check_interval: '1s',
          limit_mib: 900,
          spike_limit_percentage: 15,
        },
        k8s_attributes: {
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
        'resource/k8s-events-receiver': {
          attributes: [
            {
              action: 'upsert',
              key: 'service.name',
              value: 'k8s-events-receiver',
            },
            {
              action: 'upsert',
              key: 'service.namespace',
              value: 'k8s-events-receiver',
            },
          ],
        },
      },
      service: {
        // telemetry: {
        //   logs: {
        //     level: 'DEBUG',
        //     development: true,
        //     encoding: 'json',
        //   },
        // },
        pipelines: {
          metrics: {
            receivers: [
              'k8s_cluster',
              'prometheus',
            ],
            processors: [
              'memory_limiter',
              'k8s_attributes',
              'resource/cluster_name',
            ],
            exporters: [
              'prometheus_remote_write/victoriametrics',
            ],
          },
          logs: {
            receivers: [
              'k8s_events',
            ],
            processors: [
              'memory_limiter',
              'k8s_attributes',
              'resource/k8s-events-receiver',
              'resource/cluster_name',
            ],
            exporters: [
              'otlp_http/loki',
            ],
          },
        },
      },
    },
    resources: {
      requests: {
        cpu: '30m',
        memory: '128Mi',
      },
      limits: {
        cpu: '500m',
        memory: '2Gi',
      },
    },
    tolerations: [
      {
        key: 'node.walnuts.dev/untrusted',
        operator: 'Exists',
      },
    ],
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
