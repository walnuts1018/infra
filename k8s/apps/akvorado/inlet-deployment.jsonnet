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
    strategy: {
      type: 'RollingUpdate',
      rollingUpdate: {
        maxSurge: 0,
        maxUnavailable: 1,
      },
    },
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
          image: 'quay.io/akvorado/akvorado:2.4.1@sha256:8acf8b7312ee3331bf4d348678949d4dcb134b533a1c882beb830b6d7d8a8428',
          args: ['inlet', 'http://akvorado-orchestrator:8080'],
          ports: [
            { name: 'http', containerPort: 8080, protocol: 'TCP' },
            { name: 'netflow', containerPort: 2055, protocol: 'UDP' },
            // TODO: Cilium BGPを用いたLBにしたら、hostPortやめれるかも
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
