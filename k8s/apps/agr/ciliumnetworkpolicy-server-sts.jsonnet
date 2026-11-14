local app = import 'app.json5';
local fqdn = 'seaweedfs.local.walnuts.dev';
{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-server-sts-egress',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: {
        'k8s:app.kubernetes.io/name': app.name + '-server',
      },
    },
    egress: [{
      toFQDNs: [{ matchName: fqdn }],
      toPorts: [{
        ports: [{ port: '443', protocol: 'TCP' }],
        serverNames: [fqdn],
      }],
    }],
  },
}
