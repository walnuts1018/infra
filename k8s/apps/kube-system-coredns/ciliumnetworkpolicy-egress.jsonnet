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
        'k8s:k8s-app': 'kube-dns',
      },
    },
    // The cluster-managed CoreDNS forwards external queries through /etc/resolv.conf.
    egress: [
      {
        toEntities: ['kube-apiserver'],
        toPorts: [{ ports: [{ port: '6443', protocol: 'TCP' }] }],
      },
      {
        toCIDRSet: [{ cidr: '192.168.0.1/32' }],
        toPorts: [{
          ports: [
            { port: '53', protocol: 'UDP' },
            { port: '53', protocol: 'TCP' },
          ],
        }],
      },
    ],
  },
}
