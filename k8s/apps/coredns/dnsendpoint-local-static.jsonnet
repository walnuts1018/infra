local app = import 'app.json5';
{
  apiVersion: 'externaldns.k8s.io/v1alpha1',
  kind: 'DNSEndpoint',
  metadata: {
    name: app.name + '-local-static',
    namespace: app.namespace,
  },
  spec: {
    endpoints: [
      {
        dnsName: 'seaweedfs-biscuit.local.walnuts.dev',
        recordTTL: 60,
        recordType: 'A',
        targets: [
          '192.168.16.159',
        ],
      },
      {
        dnsName: 'shutdown-manager.local.walnuts.dev',
        recordTTL: 60,
        recordType: 'A',
        targets: [
          '192.168.16.158',
        ],
      },
      {
        dnsName: 'tart.local.walnuts.dev',
        recordTTL: 60,
        recordType: 'A',
        targets: [
          '192.168.0.14',
        ],
      },
    ],
  },
}
