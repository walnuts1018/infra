local app = import 'app.json5';
local secret = import 'discovery-secret.jsonnet';
{
  apiVersion: 'opentelemetry.io/v1beta1',
  kind: 'OpenTelemetryCollector',
  metadata: {
    name: 'iwashi-collector',
    namespace: app.namespace,
  },
  spec: {
    mode: 'statefulset',
    replicas: 1,
    serviceName: 'iwashi-collector-headless',
    image: 'ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.160.0',
    serviceAccount: 'iwashi-collector',
    ports: [{
      name: 'metrics',
      port: 8888,
      protocol: 'TCP',
      targetPort: 8888,
    }],
    env: [{
      name: 'DISCOVERY_KEY',
      valueFrom: {
        secretKeyRef: {
          name: secret.spec.target.name,
          key: 'DISCOVERY_KEY',
        },
      },
    }],
    resources: {
      requests: { cpu: '20m', memory: '128Mi' },
      limits: { memory: '512Mi' },
    },
    podSecurityContext: {
      runAsNonRoot: true,
      seccompProfile: { type: 'RuntimeDefault' },
    },
    securityContext: {
      allowPrivilegeEscalation: false,
      readOnlyRootFilesystem: true,
      runAsNonRoot: true,
      capabilities: { drop: ['ALL'] },
    },
    config: {
      receivers: {
        prometheus: {
          config: {
            scrape_configs: [{
              job_name: 'iwashi-http-probes',
              scrape_interval: '60s',
              scrape_timeout: '10s',
              metrics_path: '/probe',
              params: { module: ['http_2xx'] },
              http_sd_configs: [{
                url: 'http://iwashi.iwashi-system.svc.cluster.local:8080/internal/discovery/standard',
                refresh_interval: '15s',
                authorization: {
                  type: 'Bearer',
                  credentials: '${env:DISCOVERY_KEY}',
                },
              }],
              relabel_configs: [
                {
                  source_labels: ['__address__'],
                  target_label: '__param_target',
                },
                {
                  source_labels: ['__param_target'],
                  target_label: 'instance',
                },
                {
                  target_label: '__address__',
                  replacement: 'iwashi-blackbox-prometheus-blackbox-exporter.iwashi-blackbox.svc.cluster.local:9115',
                },
              ],
            }],
          },
        },
      },
      exporters: {
        otlp_http: {
          metrics_endpoint: 'http://iwashi.iwashi-system.svc.cluster.local:8080/internal/otlp/v1/metrics',
          headers: { Authorization: 'Bearer ${env:DISCOVERY_KEY}' },
          compression: 'none',
        },
      },
      service: {
        telemetry: {
          metrics: {
            readers: [{
              pull: {
                exporter: {
                  prometheus: {
                    host: '0.0.0.0',
                    port: 8888,
                    without_scope_info: true,
                    without_type_suffix: true,
                    without_units: true,
                  },
                },
              },
            }],
          },
        },
        pipelines: {
          metrics: {
            receivers: ['prometheus'],
            exporters: ['otlp_http'],
          },
        },
      },
    },
  },
}
