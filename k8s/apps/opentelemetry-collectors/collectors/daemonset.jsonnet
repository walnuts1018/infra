std.mergePatch((import '_base.libsonnet'), {
  metadata: {
    name: 'daemonset',
  },
  spec: {
    mode: 'daemonset',
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
        journald: {
          directory: '/var/log/journal',
          units: [
            'kubelet.service',
          ],
          priority: 'info',
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
          ],
        },
      },
      service: {
        pipelines: {
          logs: {
            receivers: [
              'filelog',
            ],
            processors: [
              'memory_limiter',
              'batch',
              'k8sattributes',
            ],
            exporters: [
              'otlphttp/loki',
            ],
          },
          'logs/journald': {
            receivers: [
              'journald',
            ],
            processors: [
              'memory_limiter',
              'batch',
              'k8sattributes',
              'resource/journald',
            ],
            exporters: [
              'otlphttp/loki',
            ],
          },
          metrics: {
            receivers: [
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
              'prometheusremotewrite',
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
        name: 'varlibdockercontainers',
        hostPath: {
          path: '/var/lib/docker/containers',
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
    ],
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
    ],
    securityContext: {
      runAsUser: 0,
      runAsGroup: 0,
    },
  },
})
