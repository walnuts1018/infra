local app = import 'app.json5';
local geminiFqdn = 'generativelanguage.googleapis.com';
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
          rules: { dns: [{ matchPattern: '*' }] },
        }],
      },
      {
        toFQDNs: [{ matchName: geminiFqdn }],
        toPorts: [{ ports: [{ port: '443', protocol: 'TCP' }] }],
      },
    ],
  },
}
