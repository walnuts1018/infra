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
          args: ['inlet', 'http://akvorado-orchestrator:8080'],
          ports: [
            { name: 'http', containerPort: 8080, protocol: 'TCP' },
            { name: 'netflow', containerPort: 2055, protocol: 'UDP' },
            // Cilium BGPを用いたLBにしたら、hostPortやめれるかも
            { name: 'sflow', containerPort: 6343, hostPort: 6343, protocol: 'UDP' },
          ],
          volumeMounts: [],
          resources: {
            requests: { cpu: '2m', memory: '14Mi' },
            limits: { cpu: '2', memory: '1Gi' },
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
        nodeSelector: {
          'kubernetes.io/hostname': 'cake',
        },
      },
    },
  },
}
