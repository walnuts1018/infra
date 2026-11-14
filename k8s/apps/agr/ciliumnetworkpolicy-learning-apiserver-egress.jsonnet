local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-learning-apiserver-egress',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: labels(app.name + '-learning'),
    },
    egress: [{
      toEntities: ['kube-apiserver'],
      toPorts: [{
        ports: [
          { port: '443', protocol: 'TCP' },
          { port: '6443', protocol: 'TCP' },
        ],
      }],
    }],
  },
}
