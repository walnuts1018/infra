local app = import 'app.json5';

{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-apiserver-egress',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: {
        'k8s:app.kubernetes.io/instance': app.name,
        'k8s:app.kubernetes.io/name': 'external-dns',
      },
    },
    egress: [{
      toEntities: ['kube-apiserver'],
      toPorts: [{
        ports: [
          { port: '443', protocol: 'TCP' },
          { port: '6443', protocol: 'TCP' },
        ],
      }],
    }],
  },
}
