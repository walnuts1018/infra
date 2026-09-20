local app = import 'app.json5';
local deployment = import 'deployment.jsonnet';
local runnerStatefulSet = import 'runner-statefulset.jsonnet';
{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-runner-egress',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: {
        'k8s:app.kubernetes.io/part-of': runnerStatefulSet.metadata.labels['app.kubernetes.io/part-of'],
        'k8s:app.kubernetes.io/component': runnerStatefulSet.metadata.labels['app.kubernetes.io/component'],
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
            'k8s:io.kubernetes.pod.namespace': app.namespace,
            'k8s:app.kubernetes.io/name': deployment.metadata.labels['app.kubernetes.io/name'],
            'k8s:app.kubernetes.io/component': deployment.metadata.labels['app.kubernetes.io/component'],
          },
        }],
        toPorts: [{ ports: [{ port: '9000', protocol: 'TCP' }] }],
      },
    ],
  },
}
