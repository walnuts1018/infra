local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'akvorado-inlet',
    namespace: app.namespace,
    labels: labels('akvorado'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: {
        'app.kubernetes.io/name': 'akvorado',
        'app.kubernetes.io/component': 'inlet',
      },
    },
    template: {
      metadata: {
        labels: labels('akvorado') + {
          'app.kubernetes.io/component': 'inlet',
        },
      },
      spec: {
        containers: [{
          name: 'inlet',
          image: 'quay.io/akvorado/akvorado:2.4.1',
          args: ['inlet', '--http', '0.0.0.0:8080', 'http://akvorado-orchestrator:8080'],
          ports: [
            { name: 'http', containerPort: 8080, protocol: 'TCP' },
            { name: 'netflow', containerPort: 2055, protocol: 'UDP' },
            { name: 'sflow', containerPort: 6343, protocol: 'UDP' },
          ],
          volumeMounts: [
            { name: 'config', mountPath: '/etc/akvorado' },
            { name: 'snmp-config', mountPath: '/etc/akvorado/snmp.yaml', subPath: 'snmp.yaml' },
          ],
          resources: {
            requests: { cpu: '100m', memory: '128Mi' },
            limits: { cpu: '2', memory: '1Gi' },
          },
          livenessProbe: {
            httpGet: { path: '/api/v0/healthz', port: 8080 },
            initialDelaySeconds: 30,
            periodSeconds: 30,
          },
          readinessProbe: {
            httpGet: { path: '/api/v0/healthz', port: 8080 },
            initialDelaySeconds: 10,
            periodSeconds: 10,
          },
        }],
        volumes: [
          { name: 'config', configMap: { name: 'akvorado-config' } },
          { name: 'snmp-config', secret: { secretName: (import 'external-secret-snmp.jsonnet').spec.target.name } },
        ],
      },
    },
  },
}
