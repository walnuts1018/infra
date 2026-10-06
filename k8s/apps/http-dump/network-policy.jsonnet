local app = import 'app.json5';

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: (import '../../components/labels.libsonnet')(app.name),
    },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [{
      from: [{
        namespaceSelector: {
          matchLabels: { 'kubernetes.io/metadata.name': 'keda' },
        },
      }],
      ports: [{ protocol: 'TCP', port: 8080 }],
    }],
    egress: [
      {
        to: [{
          namespaceSelector: {
            matchLabels: { 'kubernetes.io/metadata.name': 'kube-system' },
          },
          podSelector: {
            matchLabels: { 'k8s-app': 'kube-dns' },
          },
        }],
        ports: [
          { protocol: 'UDP', port: 53 },
          { protocol: 'TCP', port: 53 },
        ],
      },
      {
        to: [{
          namespaceSelector: {
            matchLabels: { 'kubernetes.io/metadata.name': 'opentelemetry-collector' },
          },
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/component': 'opentelemetry-collector',
              'app.kubernetes.io/instance': 'opentelemetry-collector.default',
              'app.kubernetes.io/name': 'default-collector',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 4317 }],
      },
    ],
  },
}
