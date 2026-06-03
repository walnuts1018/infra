local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'discovery.k8s.io/v1',
  kind: 'EndpointSlice',
  metadata: {
    name: 'kubelet',
    namespace: 'kube-system',
    labels: labels(app.name) + {
      'app.kubernetes.io/name': 'kubelet',
      'endpointslice.kubernetes.io/managed-by': 'argocd',
      'k8s-app': 'kubelet',
      'kubernetes.io/service-name': 'kubelet',
    },
  },
  addressType: 'IPv4',
  endpoints: [
    // TODO: 手動で書くのやめたい
    {
      addresses: ['192.168.0.25'],
      conditions: {
        ready: true,
      },
      nodeName: 'cake',
      targetRef: {
        kind: 'Node',
        name: 'cake',
      },
    },
    {
      addresses: ['192.168.0.26'],
      conditions: {
        ready: true,
      },
      nodeName: 'hotate',
      targetRef: {
        kind: 'Node',
        name: 'hotate',
      },
    },
    {
      addresses: ['192.168.0.19'],
      conditions: {
        ready: true,
      },
      nodeName: 'lemon',
      targetRef: {
        kind: 'Node',
        name: 'lemon',
      },
    },
    {
      addresses: ['192.168.0.20'],
      conditions: {
        ready: true,
      },
      nodeName: 'rusk',
      targetRef: {
        kind: 'Node',
        name: 'rusk',
      },
    },
  ],
  ports: [
    {
      name: 'https-metrics',
      port: 10250,
      protocol: 'TCP',
    },
    {
      name: 'cadvisor',
      port: 4194,
      protocol: 'TCP',
    },
    {
      name: 'http-metrics',
      port: 10255,
      protocol: 'TCP',
    },
  ],
}
