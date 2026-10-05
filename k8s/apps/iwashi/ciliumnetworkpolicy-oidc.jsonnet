local app = import 'app.json5';
{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-oidc-egress',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: { 'app.kubernetes.io/name': app.name },
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
        toFQDNs: [{ matchName: 'auth.walnuts.dev' }],
        toPorts: [{ ports: [{ port: '443', protocol: 'TCP' }] }],
      },
    ],
  },
}
