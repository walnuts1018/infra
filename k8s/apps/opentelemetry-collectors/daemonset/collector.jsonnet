function(
  clusterName='kurumi',
) {
  apiVersion: 'opentelemetry.io/v1beta1',
  kind: 'OpenTelemetryCollector',
  metadata: {
    name: 'daemonset',
  },
  spec: {
    managementState: 'managed',
    image: 'ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.162.0',
    serviceAccount: (import 'sa.jsonnet').metadata.name,
    mode: 'daemonset',
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
          limit_mib: 2000,
          spike_limit_percentage: 15,
        },
        k8s_attributes: {
          auth_type: 'serviceAccount',
          filter: {
            node_from_env_var: 'K8S_NODE_NAME',
          },
          extract: {
            metadata: [
              'k8s.namespace.name',
              'k8s.pod.name',
              'k8s.pod.start_time',
              'k8s.pod.uid',
              'k8s.deployment.name',
              'k8s.deployment.uid',
              'k8s.node.name',
              'k8s.cluster.uid',
              'k8s.cronjob.name',
              'k8s.job.name',
              'k8s.daemonset.name',
              'k8s.daemonset.uid',
              'k8s.statefulset.name',
              'k8s.statefulset.uid',
              'container.id',
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
        resource_detection: {
          detectors: [
            'env',
          ],
          timeout: '15s',
          override: false,
        },
        'transform/jsonparse': {
          error_mode: 'ignore',
          log_statements: [
            {
              context: 'log',
              statements: [
                'merge_maps(cache, ParseJSON(body), "upsert") where IsMatch(body, "^\\\\{")',
                'set(body, cache["msg"]) where cache["msg"] != nil',
                'delete_key(cache, "msg")',
                'truncate_all(cache, 1024)',
                'limit(cache, 100, [])',
                'merge_maps(resource.attributes, cache, "insert")',
              ],
            },
          ],
        },
        'resource/journald': {
          attributes: [
            {
              key: 'service.name',
              action: 'upsert',
              value: 'journald',
            },
            {
              key: 'service.namespace',
              action: 'upsert',
              value: 'journald',
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
        file_log: {
          include_file_path: true,
          include: [
            '/var/log/pods/*/*/*.log',
          ],
          operators: [
            {
              id: 'container-parser',
              type: 'container',
            },
          ],
        },
        host_metrics: {
          collection_interval: '10s',
          scrapers: {
            cpu: {
              metrics: {
                'system.cpu.logical.count': {
                  enabled: true,
                },
              },
            },
            memory: {
              metrics: {
                'system.memory.limit': {
                  enabled: true,
                },
                'system.linux.memory.available': {
                  enabled: true,
                },
              },
            },
            system: {
              metrics: {
                'system.uptime': {
                  enabled: true,
                },
              },
            },
          },
        },
        kubelet_stats: {
          collection_interval: '10s',
          auth_type: 'serviceAccount',
          endpoint: '${env:K8S_NODE_IP}:10250',
          insecure_skip_verify: true,
          extra_metadata_labels: [
            'k8s.volume.type',
          ],
          k8s_api_config: {
            auth_type: 'serviceAccount',
          },
          metric_groups: [
            'node',
            'pod',
            'container',
            'volume',
          ],
        },
        journald: {
          directory: '/var/log/journal',
          units: [
            'kubelet.service',
          ],
          priority: 'info',
        },
      },
      service: {
        pipelines: {
          logs: {
            receivers: [
              'file_log',
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
          'logs/mackerel': {
            receivers: [
              'file_log',
            ],
            processors: [
              'memory_limiter',
              'k8s_attributes',
              'resource/cluster_name',
              'transform/add_sample_key',
              'probabilistic_sampler/mackerel',
              'transform/remove_sample_key',
            ],
            exporters: [
              'otlp_http/mackerel',
            ],
          },
          'logs/journald': {
            receivers: [
              'journald',
            ],
            processors: [
              'memory_limiter',
              'k8s_attributes',
              'resource/journald',
              'resource/cluster_name',
            ],
            exporters: [
              'otlp_http/loki',
            ],
          },
          metrics: {
            receivers: [
              'host_metrics',
              'kubelet_stats',
            ],
            processors: [
              'memory_limiter',
              'k8s_attributes',
              'resource_detection',
              'resource/cluster_name',
            ],
            exporters: [
              'prometheus_remote_write/victoriametrics',
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
      {
        name: 'OTEL_RESOURCE_ATTRIBUTES',
        value: 'k8s.node.name=$(K8S_NODE_NAME),k8s.node.ip=$(K8S_NODE_IP)',
      },
    ],
    resources: {
      requests: {
        cpu: '100m',
        memory: '150Mi',
      },
      limits: {
        cpu: '500m',
      },
    },
    // tolerations: [
    //   {
    //     operator: 'Exists',
    //   },
    // ],
    volumes: [
      {
        name: 'varlogpods',
        hostPath: {
          path: '/var/log/pods',
        },
      },
      {
        name: 'varlogjournal',
        hostPath: {
          path: '/var/log/journal',
        },
      },
      {
        name: 'journalctl',
        hostPath: {
          path: '/usr/bin/journalctl',
          type: 'File',
        },
      },
      {
        name: 'usrlib',
        hostPath: {
          path: '/usr/lib',
          type: 'Directory',
        },
      },
      {
        name: 'lib',
        hostPath: {
          path: '/lib',
          type: 'Directory',
        },
      },
      {
        name: 'lib64',
        hostPath: {
          path: '/lib64',
          type: 'Directory',
        },
      },
      {
        name: 'tmp',
        emptyDir: {},
      },
    ],
    volumeMounts: [
      {
        name: 'varlogpods',
        mountPath: '/var/log/pods',
        readOnly: true,
      },
      {
        name: 'varlogjournal',
        mountPath: '/var/log/journal',
        readOnly: true,
      },
      {
        name: 'journalctl',
        mountPath: '/usr/bin/journalctl',
        readOnly: true,
      },
      {
        name: 'usrlib',
        mountPath: '/usr/lib',
        readOnly: true,
      },
      {
        name: 'lib',
        mountPath: '/lib',
        readOnly: true,
      },
      {
        name: 'lib64',
        mountPath: '/lib64',
        readOnly: true,
      },
      {
        name: 'tmp',
        mountPath: '/tmp',
      },
    ],
    securityContext: {
      runAsUser: 0,
      runAsGroup: 0,
    },
  },
}
