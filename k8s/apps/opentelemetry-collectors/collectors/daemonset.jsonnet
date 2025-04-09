std.mergePatch((import '_base.libsonnet'), {
  metadata: {
    name: 'k8s-daemonset',
  },
  spec: {
    serviceAccount: (import '../sa.jsonnet').metadata.name,
    mode: 'daemonset',
    image: 'otel/opentelemetry-collector-contrib:0.122.1',
    config: {
      receivers: {
        filelog: {
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
        hostmetrics: {
          collection_interval: '10s',
          scrapers: {
            cpu: {
              metrics: {
                'system.cpu.logical.count': {
                  enabled: true,
                },
              },
            },
            load: null,
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
            disk: null,
            filesystem: null,
            network: null,
            system: {
              metrics: {
                'system.uptime': {
                  enabled: true,
                },
              },
            },
          },
        },
        kubeletstats: {
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
        resourcedetection: {
          detectors: [
            'env',
          ],
          timeout: '15s',
          override: false,
        },
        'transform/logsize': {
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
            {
              context: 'log',
              statements: [
                'set(attributes["body_size"], Len(log.body))',
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
        debug: {
          verbosity: 'detailed',
        },
      },
      connectors: {
        'sum/logsize': {
          logs: {
            'logs.size': {
              source_attribute: 'body_size',
              conditions: [
                'attributes["body_size"] != "NULL"',
              ],
              attributes: [
                {
                  key: 'k8s.cluster.uid',
                },
                {
                  key: 'k8s.namespace.name',
                },
                {
                  key: 'k8s.deployment.name',
                },
                {
                  key: 'k8s.pod.name',
                },
                {
                  key: 'k8s.pod.uid',
                },
                {
                  key: 'k8s.container.name',
                },
                {
                  key: 'container.id',
                },
              ],
            },
          },
        },
      },
      service: {
        pipelines: {
          metrics: {
            receivers: [
              'sum/logsize',
              'hostmetrics',
              'kubeletstats',
            ],
            processors: [
              'memory_limiter',
              'batch',
              'k8sattributes',
              'resourcedetection',
            ],
            exporters: [
              'otlp/default',
            ],
          },
          logs: {
            receivers: [
              'filelog',
            ],
            processors: [
              'memory_limiter',
              'batch',
              'transform/logsize',
            ],
            exporters: [
              'otlp/default',
              'sum/logsize',
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
        name: 'OTEL_RESOURCE_ATTRIBUTES',
        value: 'k8s.node.name=$(K8S_NODE_NAME),k8s.node.ip=$(K8S_NODE_IP)',
      },
    ],
    resources: {
      requests: {
        cpu: '100m',
        memory: '150Mi',
      },
    },
    // tolerations: [
    //   {
    //     operator: 'Exists',
    //   },
    // ],
    volumeMounts: [
      {
        name: 'varlogpods',
        mountPath: '/var/log/pods',
        readOnly: true,
      },
      {
        name: 'varlibdockercontainers',
        mountPath: '/var/lib/docker/containers',
        readOnly: true,
      },
    ],
    volumes: [
      {
        name: 'varlogpods',
        hostPath: {
          path: '/var/log/pods',
        },
      },
      {
        name: 'varlibdockercontainers',
        hostPath: {
          path: '/var/lib/docker/containers',
        },
      },
    ],
    securityContext: {
      runAsUser: 0,
      runAsGroup: 0,
    },
  },
})
