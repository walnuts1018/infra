function(
  clusterName='kurumi',
) {
  apiVersion: 'opentelemetry.io/v1beta1',
  kind: 'OpenTelemetryCollector',
  metadata: {
    name: 'prometheus',
  },
  spec: {
    managementState: 'managed',
    image: 'ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.162.0',
    serviceAccount: (import 'sa.jsonnet').metadata.name,
    replicas: 2,
    mode: 'statefulset',
    targetAllocator: {
      enabled: true,
      serviceAccount: (import 'targetallocator-sa.jsonnet').metadata.name,
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
      securityContext: {
        runAsNonRoot: true,
        runAsUser: 65532,
        runAsGroup: 65532,
        allowPrivilegeEscalation: false,
        readOnlyRootFilesystem: true,
        capabilities: {
          drop: ['ALL'],
        },
        seccompProfile: {
          type: 'RuntimeDefault',
        },
      },
      mtls: {
        enabled: true,
        useCertManager: true,
      },
    },
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
            enabled: false,
          },
          disable_scope_info: true,
          target_info: {
            enabled: false,
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
                      'iwashi-cortex-distributor.iwashi-system.svc.cluster.local:8080',
                    ],
                    labels: { cortex_component: 'distributor' },
                  },
                  {
                    targets: [
                      'iwashi-cortex-ingester.iwashi-system.svc.cluster.local:8080',
                    ],
                    labels: { cortex_component: 'ingester' },
                  },
                  {
                    targets: [
                      'iwashi-cortex-querier.iwashi-system.svc.cluster.local:8080',
                    ],
                    labels: { cortex_component: 'querier' },
                  },
                  {
                    targets: [
                      'iwashi-cortex-store-gateway.iwashi-system.svc.cluster.local:8080',
                    ],
                    labels: { cortex_component: 'store-gateway' },
                  },
                  {
                    targets: [
                      'iwashi-cortex-compactor.iwashi-system.svc.cluster.local:8080',
                    ],
                    labels: { cortex_component: 'compactor' },
                  },
                  {
                    targets: [
                      'iwashi-cortex-ruler.iwashi-system.svc.cluster.local:8080',
                    ],
                    labels: { cortex_component: 'ruler' },
                  },
                  {
                    targets: [
                      'iwashi-cortex-alertmanager.iwashi-system.svc.cluster.local:8080',
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
                      'iwashi.iwashi-system.svc.cluster.local:8080',
                    ],
                  },
                ],
              },
              {
                job_name: 'iwashi-collector',
                scrape_interval: '30s',
                metrics_path: '/metrics',
                static_configs: [
                  {
                    targets: [
                      'iwashi-collector-collector-monitoring.iwashi-system.svc.cluster.local:8888',
                    ],
                  },
                ],
              },
            ],
          },
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
