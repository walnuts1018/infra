local app = import 'app.json5';

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
        'k8s:app.kubernetes.io/name': app.name,
      },
    },
    egress: [
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'coredns',
            'k8s:app.kubernetes.io/name': 'coredns',
          },
        }],
        toPorts: [{
          ports: [
            { port: '53', protocol: 'UDP' },
            { port: '53', protocol: 'TCP' },
          ],
          rules: {
            dns: [{ matchName: 'auth.walnuts.dev' }],
          },
        }],
      },
      {
        toEntities: ['kube-apiserver'],
      },
      {
        toFQDNs: [{ matchName: 'auth.walnuts.dev' }],
        toPorts: [{
          ports: [{ port: '443', protocol: 'TCP' }],
        }],
      },
    ],
  },
}
