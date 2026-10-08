local app = import 'app.json5';

local downloadHost = 'download.versatiles.org';

{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-update-egress',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: {
        'k8s:app.kubernetes.io/name': app.name + '-update',
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
          rules: {
            dns: [{ matchPattern: '*' }],
          },
        }],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'seaweedfs',
            'k8s:app.kubernetes.io/component': 's3',
            'k8s:app.kubernetes.io/instance': 'seaweedfs-default',
            'k8s:app.kubernetes.io/name': 'seaweedfs',
          },
        }],
        toPorts: [{ ports: [{ port: '8333', protocol: 'TCP' }] }],
      },
      {
        toEntities: ['kube-apiserver'],
        toPorts: [{
          ports: [
            { port: '443', protocol: 'TCP' },
            { port: '6443', protocol: 'TCP' },
          ],
        }],
      },
      {
        toFQDNs: [{ matchName: downloadHost }],
        toPorts: [{ ports: [{ port: '443', protocol: 'TCP' }] }],
      },
    ],
  },
}
