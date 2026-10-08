local networkPolicy = import '../../components/network-policy.libsonnet';
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
        'app.kubernetes.io/name': 'coder-workspace',
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
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'coder',
            'k8s:app.kubernetes.io/name': 'coder',
            'k8s:app.kubernetes.io/instance': 'coder',
          },
        }],
        toPorts: [{
          ports: [{ port: '8080', protocol: 'TCP' }],
        }],
      },
      {
        toCIDRSet: networkPolicy.publicInternetCIDRSet,
      },
    ],
  },
}
