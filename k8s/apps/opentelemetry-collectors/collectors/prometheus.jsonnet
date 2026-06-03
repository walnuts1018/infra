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
          cpu: '26m',
          memory: '167Mi',
        },
        limits: {
          cpu: '2',
          memory: '3Gi',
        },
      },
    },
    config: {
      receivers: {
        prometheus: {
          config: {
            scrape_configs: [],
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
              'k8s_attributes',
              'resource/cluster_name',
            ],
            exporters: [
              'prometheusremotewrite/victoriametrics',
            ],
          },
        },
      },
    },
    resources: {
      requests: {
        cpu: '550m',
        memory: '2.2Gi',
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
