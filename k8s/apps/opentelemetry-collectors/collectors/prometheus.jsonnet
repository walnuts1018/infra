function(
  clusterName='kurumi',
) std.mergePatch((import '_base.libsonnet')(
  clusterName,
), {
  metadata: {
    name: 'prometheus',
  },
  spec: {
    replicas: 2,
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
      resources: {
        requests: {
          cpu: '10m',
          memory: '167Mi',
        },
        limits: {
          cpu: '2',
          memory: '3Gi',
        },
      },
    },
    config: {
      exporters: {
        'prometheus_remote_write/victoriametrics': {
          disable_scope_info: true,
          resource_to_telemetry_conversion: {
            enabled: false,
          },
          target_info: {
            enabled: false,
          },
        },
      },
      receivers: {
        prometheus: {
          config: {
            scrape_configs: [
              {
                job_name: 'cortex',
                scrape_interval: '30s',
                metrics_path: '/metrics',
                static_configs: [
                  {
                    targets: [
                      'iwashi-cortex-distributor.cortex.svc.cluster.local:8080',
                    ],
                    labels: { cortex_component: 'distributor' },
                  },
                  {
                    targets: [
                      'iwashi-cortex-ingester.cortex.svc.cluster.local:8080',
                    ],
                    labels: { cortex_component: 'ingester' },
                  },
                  {
                    targets: [
                      'iwashi-cortex-querier.cortex.svc.cluster.local:8080',
                    ],
                    labels: { cortex_component: 'querier' },
                  },
                  {
                    targets: [
                      'iwashi-cortex-store-gateway.cortex.svc.cluster.local:8080',
                    ],
                    labels: { cortex_component: 'store-gateway' },
                  },
                  {
                    targets: [
                      'iwashi-cortex-compactor.cortex.svc.cluster.local:8080',
                    ],
                    labels: { cortex_component: 'compactor' },
                  },
                  {
                    targets: [
                      'iwashi-cortex-ruler.cortex.svc.cluster.local:8080',
                    ],
                    labels: { cortex_component: 'ruler' },
                  },
                  {
                    targets: [
                      'iwashi-cortex-alertmanager.cortex.svc.cluster.local:8080',
                    ],
                    labels: { cortex_component: 'alertmanager' },
                  },
                ],
              },
              {
                job_name: 'iwashi',
                scrape_interval: '30s',
                metrics_path: '/metrics',
                static_configs: [
                  {
                    targets: [
                      'iwashi.monitoring-app.svc.cluster.local:8080',
                    ],
                  },
                ],
              },
              {
                job_name: 'synthetic-otel-collector',
                scrape_interval: '30s',
                metrics_path: '/metrics',
                static_configs: [
                  {
                    targets: [
                      'synthetic-otel-collector-collector-monitoring.synthetic-monitoring.svc.cluster.local:8888',
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
          limit_mib: 3500,
          spike_limit_mib: 200,
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
      },
      service: {
        pipelines: {
          metrics: {
            receivers: [
              'prometheus',
            ],
            processors: [
              'memory_limiter',
            ],
            exporters: [
              'prometheus_remote_write/victoriametrics',
            ],
          },
        },
      },
    },
    resources: {
      requests: {
        cpu: '250m',
        memory: '1Gi',
      },
      limits: {
        cpu: '1500m',
        memory: '4Gi',
      },
    },
    tolerations: [
      {
        key: 'node.walnuts.dev/untrusted',
        operator: 'Exists',
      },
    ],
  },
})
