local app = import 'app.json5';

local endpoint = function(namespace, labels) {
  matchLabels: {
    'k8s:io.kubernetes.pod.namespace': namespace,
  } + labels,
};

local etcd = endpoint(app.namespace, {
  'k8s:app': app.name + '-etcd',
  'k8s:app.kubernetes.io/name': app.name + '-etcd',
});

{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-etcd-ingress',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: etcd,
    ingress: [
      {
        fromEndpoints: [
          endpoint(app.namespace, {
            'k8s:app': app.name,
            'k8s:app.kubernetes.io/name': app.name,
          }),
          endpoint('external-dns-coredns', {
            'k8s:app.kubernetes.io/instance': 'external-dns-coredns',
            'k8s:app.kubernetes.io/name': 'external-dns',
          }),
        ],
        toPorts: [{ ports: [{ port: '2379', protocol: 'TCP' }] }],
      },
      {
        fromEndpoints: [etcd],
        toPorts: [{ ports: [{ port: '2380', protocol: 'TCP' }] }],
      },
      {
        fromEntities: ['host'],
        toPorts: [{ ports: [{ port: '2379', protocol: 'TCP' }] }],
      },
    ],
  },
}
