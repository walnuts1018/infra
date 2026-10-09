local app = import 'app.json5';
local apiFqdn = 'api.cloudflare.com';
// Go's resolver tries these search-list names before the absolute name with ndots:5.
local apiDnsSearchNames = [
  apiFqdn + '.' + app.namespace + '.svc.cluster.local',
  apiFqdn + '.svc.cluster.local',
  apiFqdn + '.cluster.local',
];

{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-egress',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: {
        'k8s:app.kubernetes.io/instance': app.name,
        'k8s:app.kubernetes.io/name': 'external-dns',
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
          rules: {
            dns: [{ matchName: name } for name in apiDnsSearchNames] + [
              { matchName: apiFqdn },
            ],
          },
        }],
      },
      {
        toEntities: ['kube-apiserver'],
        toPorts: [{
          ports: [
            { port: '443', protocol: 'TCP' },
            { port: '6443', protocol: 'TCP' },
          ],
        }],
      },
      {
        toFQDNs: [{ matchName: apiFqdn }],
        toPorts: [{ ports: [{ port: '443', protocol: 'TCP' }] }],
      },
    ],
  },
}
