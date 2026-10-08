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
        'k8s:app.kubernetes.io/instance': app.name,
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
            'k8s:io.kubernetes.pod.namespace': 'databases',
            'k8s:cnpg.io/cluster': 'postgresql-default',
            'k8s:cnpg.io/instanceRole': 'primary',
          },
        }],
        toPorts: [{ ports: [{ port: '5432', protocol: 'TCP' }] }],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': app.namespace,
            'k8s:app.kubernetes.io/instance': app.name,
            'k8s:app.kubernetes.io/name': 'valkey',
          },
        }],
        toPorts: [{ ports: [{ port: '6379', protocol: 'TCP' }] }],
      },
      {
        toFQDNs: [{ matchName: 'auth.walnuts.dev' }],
        toPorts: [{ ports: [{ port: '443', protocol: 'TCP' }] }],
      },
      {
        toFQDNs: [{ matchName: 'seaweedfs.local.walnuts.dev' }],
        toPorts: [{ ports: [{ port: '443', protocol: 'TCP' }] }],
      },
      {
        toFQDNs: [{ matchName: 'smtp.resend.com' }],
        toPorts: [{ ports: [{ port: '587', protocol: 'TCP' }] }],
      },
    ],
  },
}
