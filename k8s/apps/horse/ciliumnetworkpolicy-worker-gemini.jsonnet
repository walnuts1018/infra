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
        toFQDNs: [{ matchName: geminiFqdn }],
        toPorts: [{
          ports: [{ port: '443', protocol: 'TCP' }],
          serverNames: [geminiFqdn],
        }],
      },
    ],
  },
}
