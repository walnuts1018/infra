local app = import 'app.json5';
local labels = (import '../../components/labels.libsonnet')(app.name + '-alertmanager');
local secret = import 'external-secret.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: { name: app.name + '-alertmanager', namespace: app.namespace, labels: labels },
  spec: {
    replicas: 1,
    selector: { matchLabels: labels },
    template: {
      metadata: { labels: labels },
      spec: {
        containers: [{
          name: 'alertmanager',
          image: 'quay.io/prometheus/alertmanager:v0.28.1',
          args: ['--config.file=/etc/alertmanager/alertmanager.yaml', '--storage.path=/tmp/alertmanager'],
          ports: [{ name: 'http', containerPort: 9093 }],
          volumeMounts: [
            { name: 'config', mountPath: '/etc/alertmanager', readOnly: true },
            { name: 'secrets', mountPath: '/etc/iwashi-secrets', readOnly: true },
            { name: 'data', mountPath: '/tmp/alertmanager' },
          ],
          resources: { requests: { cpu: '5m', memory: '32Mi' }, limits: { memory: '128Mi' } },
          securityContext: { allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, runAsNonRoot: true, capabilities: { drop: ['ALL'] } },
        }],
        volumes: [
          { name: 'config', configMap: { name: (import 'alertmanager-config.jsonnet').metadata.name } },
          { name: 'secrets', secret: { secretName: secret.spec.target.name } },
          { name: 'data', emptyDir: {} },
        ],
        securityContext: { seccompProfile: { type: 'RuntimeDefault' } },
      },
    },
  },
}
