local app = import 'app.json5';
local geminiFqdn = 'generativelanguage.googleapis.com';
local allowedDnsNames = [
  geminiFqdn,
  'postgresql-default-rw.databases.svc.cluster.local',
  'seaweedfs-default-s3.seaweedfs.svc.cluster.local',
  'default.rabbitmq.svc.cluster.local',
  'default-collector.opentelemetry-collector.svc.cluster.local',
  app.name + '-ocr.' + app.namespace + '.svc.cluster.local',
];
{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-worker-gemini-egress',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: {
        'k8s:app.kubernetes.io/name': app.name + '-worker',
        'k8s:horse.walnuts.dev/gemini-enabled': 'true',
      },
    },
    egress: [
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'kube-system',
            'k8s:k8s-app': 'kube-dns',
          },
        }],
        toPorts: [{
          ports: [
            { port: '53', protocol: 'UDP' },
            { port: '53', protocol: 'TCP' },
          ],
          rules: { dns: [{ matchName: name } for name in allowedDnsNames] },
        }],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'databases',
            'k8s:cnpg.io/cluster': 'postgresql-default',
            'k8s:cnpg.io/instanceRole': 'primary',
          },
        }],
        toPorts: [{ ports: [{ port: '5432', protocol: 'TCP' }] }],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'seaweedfs',
            'k8s:app.kubernetes.io/component': 's3',
            'k8s:app.kubernetes.io/instance': 'seaweedfs-default',
            'k8s:app.kubernetes.io/name': 'seaweedfs',
          },
        }],
        toPorts: [{ ports: [{ port: '8333', protocol: 'TCP' }] }],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'rabbitmq',
            'k8s:app.kubernetes.io/component': 'rabbitmq',
            'k8s:app.kubernetes.io/name': 'default',
          },
        }],
        toPorts: [{ ports: [{ port: '5672', protocol: 'TCP' }] }],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'opentelemetry-collector',
            'k8s:app.kubernetes.io/component': 'opentelemetry-collector',
            'k8s:app.kubernetes.io/instance': 'opentelemetry-collector.default',
            'k8s:app.kubernetes.io/name': 'default-collector',
          },
        }],
        toPorts: [{ ports: [{ port: '4318', protocol: 'TCP' }] }],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': app.namespace,
            'k8s:app': app.name + '-ocr',
            'k8s:app.kubernetes.io/name': app.name + '-ocr',
          },
        }],
        toPorts: [{ ports: [{ port: '8000', protocol: 'TCP' }] }],
      },
      {
        toFQDNs: [{ matchName: geminiFqdn }],
        toPorts: [{
          ports: [{ port: '443', protocol: 'TCP' }],
          serverNames: [geminiFqdn],
        }],
      },
    ],
  },
}
