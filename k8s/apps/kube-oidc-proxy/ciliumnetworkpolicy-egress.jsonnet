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
            'k8s:io.kubernetes.pod.namespace': 'kube-system',
            'k8s:k8s-app': 'kube-dns',
          },
        }],
        toPorts: [{
          ports: [{ port: '53', protocol: 'ANY' }],
          rules: { dns: [{ matchPattern: '*' }] },
        }],
      },
      {
        toEntities: ['kube-apiserver'],
        toPorts: [{
          ports: [{ port: '6443', protocol: 'TCP' }],
        }],
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
