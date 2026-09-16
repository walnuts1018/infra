local app = import 'app.json5';
local labels = (import '../../components/labels.libsonnet')(app.name + '-vmalert');
local secret = import 'external-secret.jsonnet';
local fetchCommand = |||
  set -eu
  curl -fsS -H "Authorization: Bearer $DISCOVERY_KEY" http://iwashi.iwashi.svc.cluster.local:8080/internal/alert-rules -o /rules/rules.yaml.tmp
  mv /rules/rules.yaml.tmp /rules/rules.yaml
|||;
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: { name: app.name + '-vmalert', namespace: app.namespace, labels: labels },
  spec: {
    replicas: 1,
    selector: { matchLabels: labels },
    template: {
      metadata: { labels: labels },
      spec: {
        initContainers: [{
          name: 'fetch-rules',
          image: 'curlimages/curl:8.16.0',
          command: ['/bin/sh', '-c', fetchCommand],
          envFrom: [{ secretRef: { name: secret.spec.target.name } }],
          volumeMounts: [{ name: 'rules', mountPath: '/rules' }],
          securityContext: { allowPrivilegeEscalation: false, runAsNonRoot: true, capabilities: { drop: ['ALL'] } },
        }],
        containers: [
          {
            name: 'vmalert',
            image: 'victoriametrics/vmalert:v1.129.0',
            args: [
              '-rule=/rules/rules.yaml',
              '-datasource.url=http://victoria-metrics-victoria-metrics-cluster-vmselect.victoria-metrics.svc.cluster.local:8481/select/multitenant/prometheus',
              '-notifier.url=http://iwashi-alertmanager.iwashi.svc.cluster.local:9093',
              '-httpListenAddr=:8880',
            ],
            ports: [{ name: 'http', containerPort: 8880 }],
            volumeMounts: [{ name: 'rules', mountPath: '/rules', readOnly: true }],
            resources: { requests: { cpu: '5m', memory: '32Mi' }, limits: { memory: '128Mi' } },
            securityContext: { allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, runAsNonRoot: true, capabilities: { drop: ['ALL'] } },
          },
          {
            name: 'rule-reloader',
            image: 'curlimages/curl:8.16.0',
            command: ['/bin/sh', '-c', fetchCommand + 'while true; do sleep 30; ' + std.strReplace(fetchCommand, '\n', '; ') + ' curl -fsS -X POST http://127.0.0.1:8880/-/reload; done'],
            envFrom: [{ secretRef: { name: secret.spec.target.name } }],
            volumeMounts: [{ name: 'rules', mountPath: '/rules' }],
            resources: { requests: { cpu: '1m', memory: '8Mi' }, limits: { memory: '32Mi' } },
            securityContext: { allowPrivilegeEscalation: false, runAsNonRoot: true, capabilities: { drop: ['ALL'] } },
          },
        ],
        volumes: [{ name: 'rules', emptyDir: {} }],
        securityContext: { seccompProfile: { type: 'RuntimeDefault' } },
      },
    },
  },
}
