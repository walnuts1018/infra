local labels = import '../../components/labels.libsonnet';
local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
local name = app.name + '-api';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: name + '-network',
    namespace: app.namespace,
  },
  spec: {
    podSelector: { matchLabels: labels(name) },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [
      {
        from: [networkPolicy.envoyGatewayProxy],
        ports: [{ protocol: 'TCP', port: 8080 }],
      },
      {
        from: [{ podSelector: { matchLabels: labels(app.name + '-web') } }],
        ports: [{ protocol: 'TCP', port: 8080 }],
      },
    ],
    egress: [
      {
        to: [networkPolicy.kubeDns],
        ports: [{ protocol: 'UDP', port: 53 }, { protocol: 'TCP', port: 53 }],
      },
      {
        to: [{
          namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'databases' } },
          podSelector: {
            matchLabels: {
              'cnpg.io/cluster': 'postgresql-default',
              'cnpg.io/instanceRole': 'primary',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 5432 }],
      },
      {
        to: [{
          namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'seaweedfs' } },
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/component': 's3',
              'app.kubernetes.io/instance': 'seaweedfs-default',
              'app.kubernetes.io/name': 'seaweedfs',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 8333 }],
      },
      {
        to: [{
          namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'rabbitmq' } },
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/component': 'rabbitmq',
              'app.kubernetes.io/name': 'default',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 5672 }],
      },
      {
        to: [{ podSelector: { matchLabels: labels(app.name + '-ocr') } }],
        ports: [{ protocol: 'TCP', port: 8000 }],
      },
      {
        to: [{
          namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'stalwart' } },
          podSelector: { matchLabels: { app: 'stalwart' } },
        }],
        ports: [{ protocol: 'TCP', port: 993 }],
      },
      {
        to: [networkPolicy.otelDefaultCollector],
        ports: [{ protocol: 'TCP', port: 4318 }],
      },
      {
        to: networkPolicy.publicInternet,
        ports: [{ protocol: 'TCP', port: 443 }],
      },
    ],
  },
}
