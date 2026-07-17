local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'akvorado-outlet',
    namespace: app.namespace,
    labels: labels('akvorado'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: {
        'app.kubernetes.io/name': 'akvorado',
        'app.kubernetes.io/component': 'outlet',
      },
    },
    template: {
      metadata: {
        labels: labels('akvorado') + {
          'app.kubernetes.io/component': 'outlet',
        },
      },
      spec: {
        containers: [{
          name: 'outlet',
          image: 'quay.io/akvorado/akvorado:2.4.1',
          args: ['outlet', '--debug', 'http://akvorado-orchestrator:8080'],
          ports: [
            { name: 'http', containerPort: 8080, protocol: 'TCP' },
          ],
          volumeMounts: [],
          resources: {
            requests: { cpu: '2m', memory: '13Mi' },
            limits: { cpu: '500m', memory: '512Mi' },
          },
          livenessProbe: {
            httpGet: { path: '/api/v0/healthcheck', port: 8080 },
            initialDelaySeconds: 30,
            periodSeconds: 30,
          },
          readinessProbe: {
            httpGet: { path: '/api/v0/healthcheck', port: 8080 },
            initialDelaySeconds: 10,
            periodSeconds: 10,
          },
        }],
        volumes: [],
      },
    },
  },
}
