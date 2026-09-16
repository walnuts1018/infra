local app = import 'app.json5';
local labels = (import '../../components/labels.libsonnet')(app.name + '-blackbox');
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: { name: app.name + '-blackbox', namespace: app.namespace, labels: labels },
  spec: {
    replicas: 1,
    selector: { matchLabels: labels },
    template: {
      metadata: { labels: labels },
      spec: {
        containers: [{
          name: 'blackbox-exporter',
          image: 'quay.io/prometheus/blackbox-exporter:v0.27.0',
          args: ['--config.file=/etc/blackbox/blackbox.yaml'],
          ports: [{ name: 'http', containerPort: 9115 }],
          volumeMounts: [{ name: 'config', mountPath: '/etc/blackbox', readOnly: true }],
          resources: { requests: { cpu: '5m', memory: '16Mi' }, limits: { memory: '128Mi' } },
          securityContext: { allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, runAsNonRoot: true, capabilities: { drop: ['ALL'] } },
        }],
        volumes: [{ name: 'config', configMap: { name: (import 'blackbox-config.jsonnet').metadata.name } }],
        securityContext: { seccompProfile: { type: 'RuntimeDefault' } },
      },
    },
  },
}
