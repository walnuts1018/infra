local app = import 'app.json5';
local secret = import 'external-secret.jsonnet';
{
  apiVersion: 'opentelemetry.io/v1beta1',
  kind: 'OpenTelemetryCollector',
  metadata: { name: app.name, namespace: app.namespace },
  spec: {
    mode: 'deployment',
    image: 'ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.160.0',
    env: [{ name: 'DISCOVERY_KEY', valueFrom: { secretKeyRef: { name: secret.spec.target.name, key: 'DISCOVERY_KEY' } } }],
    config: {
      receivers: {
        prometheus: {
          config: {
            scrape_configs: [{
              job_name: 'iwashi',
              scrape_interval: '30s',
              metrics_path: '/probe',
              params: { module: ['http_2xx'] },
              http_sd_configs: [{
                url: 'http://iwashi.iwashi.svc.cluster.local:8080/internal/prometheus-targets',
                refresh_interval: '30s',
                authorization: { type: 'Bearer', credentials: '${env:DISCOVERY_KEY}' },
              }],
              relabel_configs: [
                { source_labels: ['__address__'], target_label: '__param_target' },
                { source_labels: ['__param_target'], target_label: 'target' },
                { target_label: '__address__', replacement: 'blackbox-exporter-prometheus-blackbox-exporter.monitoring.svc.cluster.local:9115' },
              ],
            }],
          },
        },
      },
      exporters: {
        'prometheusremotewrite/victoriametrics': {
          endpoint: 'http://victoria-metrics-victoria-metrics-cluster-vminsert.victoria-metrics.svc.cluster.local:8480/insert/multitenant/prometheus/api/v1/write',
          resource_to_telemetry_conversion: { enabled: true },
        },
      },
      service: { pipelines: { metrics: { receivers: ['prometheus'], exporters: ['prometheusremotewrite/victoriametrics'] } } },
    },
    resources: { requests: { cpu: '10m', memory: '64Mi' }, limits: { memory: '256Mi' } },
  },
}
