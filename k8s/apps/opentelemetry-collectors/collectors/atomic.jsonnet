std.mergePatch((import '_base.libsonnet'), {
  metadata: {
    name: 'atomic',
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
        podMonitorSelector: {
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
              'batch',
              'k8sattributes',
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
