local app = import 'app.json5';
{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: {
        'app.kubernetes.io/name': 'mail',
        'app.kubernetes.io/instance': app.name,
      },
    },
    ingress: [{
      fromEndpoints: [{
        matchLabels: {
          'k8s:io.kubernetes.pod.namespace': 'cortex',
          'k8s:app.kubernetes.io/name': 'cortex',
          'k8s:app.kubernetes.io/instance': 'iwashi-cortex',
          'k8s:app.kubernetes.io/component': 'alertmanager',
        },
      }],
      toPorts: [{ ports: [{ port: '587', protocol: 'TCP' }] }],
    }],
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
          rules: { dns: [{ matchName: 'smtp.resend.com' }] },
        }],
      },
      {
        toFQDNs: [{ matchName: 'smtp.resend.com' }],
        toPorts: [{ ports: [{ port: '587', protocol: 'TCP' }] }],
      },
    ],
  },
}
