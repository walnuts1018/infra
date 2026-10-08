local app = import 'app.json5';

{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-webrtc-ingress',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: {
        'k8s:app': app.name,
        'k8s:app.kubernetes.io/name': app.name,
      },
    },
    ingress: [{
      fromEntities: ['world'],
      toPorts: [{
        ports: [{ port: '59000', protocol: 'UDP' }],
      }],
    }],
  },
}
