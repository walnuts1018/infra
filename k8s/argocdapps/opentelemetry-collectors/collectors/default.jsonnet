(import '_base.libsonnet') + {
  apiVersion: 'opentelemetry.io/v1beta1',
  kind: 'OpenTelemetryCollector',
  metadata: {
    name: 'default',
  },
  spec: {
    replicas: 1,
    mode: 'deployment',
    serviceAccount: 'otel-collector',
    managementState: 'managed',
    config: {
      receivers: {
        otlp: {
          protocols: {
            grpc: {
              max_recv_msg_size_mib: 100,
            },
            http: {},
          },
        },
      },
      processors: {
        memory_limiter: {
          check_interval: '5s',
          limit_mib: 2000,
          spike_limit_percentage: 15,
        },
        batch: {
          send_batch_size: 5000,
          send_batch_max_size: 5000,
          timeout: '10s',
        },
        k8sattributes: {
          auth_type: 'serviceAccount',
          passthrough: true,
          filter: {
            node_from_env_var: 'K8S_NODE_NAME',
          },
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
        'otlphttp/prometheus': {
          endpoint: 'http://prometheus-stack-kube-prom-prometheus.monitoring.svc.cluster.local:9090/api/v1/otlp',
          tls: {
            insecure: true,
          },
        },
        'otlp/tempo': {
          endpoint: 'tempo.monitoring.svc.cluster.local:4317',
          tls: {
            insecure: true,
          },
        },
        'otlp/prometheus-exporter': {
          endpoint: 'prometheus-exporter-collector.opentelemetry-collector.svc.cluster.local:4317',
          tls: {
            insecure: true,
          },
        },
        'otlphttp/vaxila': {
          endpoint: 'https://otlp-vaxila.mackerelio.com',
          headers: {
            Accept: '*/*',
            'Mackerel-Api-Key': '${env:VAXILA_APIKEY}',
          },
        },
        'otlp/signoz': {
          endpoint: 'signoz-otel-collector.signoz.svc.cluster.local:4317',
          tls: {
            insecure: true,
          },
        },
        'otlphttp/loki': {
          endpoint: 'http://loki-gateway.loki.svc.cluster.local/otlp',
          tls: {
            insecure: true,
          },
        },
      },
      service: {
        pipelines: {
          traces: {
            receivers: [
              'otlp',
            ],
            processors: [
              'memory_limiter',
              'batch',
              'k8sattributes',
            ],
            exporters: [
              'otlp/tempo',
            ],
          },
          metrics: {
            receivers: [
              'otlp',
            ],
            processors: [
              'memory_limiter',
              'batch',
              'k8sattributes',
            ],
            exporters: [
              'otlp/prometheus-exporter',
            ],
          },
          logs: {
            receivers: [
              'otlp',
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
        },
      },
    },
    autoscaler: {
      minReplicas: 1,
      maxReplicas: 5,
    },
    resources: {
      requests: {
        cpu: '20m',
        memory: '200Mi',
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
        name: 'VAXILA_APIKEY',
        valueFrom: {
          secretKeyRef: {
            name: 'opentelemetry-collector',
            key: 'vaxila-api-key',
          },
        },
      },
    ],
  },
}
