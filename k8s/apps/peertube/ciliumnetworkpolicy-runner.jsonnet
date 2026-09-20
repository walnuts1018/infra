local app = import 'app.json5';
{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-runner-egress',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: {
        'k8s:app.kubernetes.io/part-of': app.name,
        'k8s:app.kubernetes.io/component': 'runner',
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
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': app.namespace,
            'k8s:app.kubernetes.io/name': app.name,
            'k8s:app.kubernetes.io/component': 'server',
          },
        }],
        toPorts: [{ ports: [{ port: '9000', protocol: 'TCP' }] }],
      },
    ],
  },
}
