local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'akvorado-console',
    namespace: app.namespace,
    labels: labels('akvorado'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: {
        'app.kubernetes.io/name': 'akvorado',
        'app.kubernetes.io/component': 'console',
      },
    },
    template: {
      metadata: {
        labels: labels('akvorado') + {
          'app.kubernetes.io/component': 'console',
        },
      },
      spec: {
        containers: [{
          name: 'console',
          image: 'quay.io/akvorado/akvorado:2.4.1',
          args: ['console', 'http://akvorado-orchestrator:8080'],
          ports: [
            { name: 'http', containerPort: 8080, protocol: 'TCP' },
          ],
          volumeMounts: [
            { name: 'config', mountPath: '/etc/akvorado' },
          ],
          env: [
            {
              name: 'AKVORADO_CFG_INLET_SNMP_COMMUNITIES_0_COMMUNITY',
              valueFrom: {
                secretKeyRef: {
                  name: (import 'external-secret-snmp.jsonnet').metadata.name,
                  key: 'snmp_community',
                },
              },
            },
          ],
          resources: {
            requests: { cpu: '50m', memory: '64Mi' },
            limits: { cpu: '500m', memory: '512Mi' },
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
          { name: 'config', configMap: { name: (import 'configmap.jsonnet').metadata.name } },
        ],
      },
    },
  },
}
