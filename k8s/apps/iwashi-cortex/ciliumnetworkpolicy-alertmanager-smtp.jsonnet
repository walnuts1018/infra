local app = import 'app.json5';
{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-alertmanager-smtp',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: {
        'app.kubernetes.io/name': 'cortex',
        'app.kubernetes.io/instance': app.name,
        'app.kubernetes.io/component': 'alertmanager',
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
        toFQDNs: [{ matchName: 'smtp.resend.com' }],
        toPorts: [{ ports: [{ port: '587', protocol: 'TCP' }] }],
      },
    ],
  },
}
