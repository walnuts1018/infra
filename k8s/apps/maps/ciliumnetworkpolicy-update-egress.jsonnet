local app = import 'app.json5';

local namespace = 'maps';
local s3Endpoint = 'seaweedfs-default-s3.seaweedfs.svc.cluster.local';
local downloadHost = 'download.versatiles.org';
local dnsNames = [
  downloadHost,
  downloadHost + '.' + namespace + '.svc.cluster.local',
  downloadHost + '.svc.cluster.local',
  downloadHost + '.cluster.local',
  s3Endpoint,
  s3Endpoint + '.' + namespace + '.svc.cluster.local',
  s3Endpoint + '.svc.cluster.local',
  s3Endpoint + '.cluster.local',
];

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
            dns: [{ matchName: name } for name in dnsNames],
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
