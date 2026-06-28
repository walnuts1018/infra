local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    selector: (labels)(app.name),
    ports: [
      {
        name: 'dns',
        protocol: 'UDP',
        port: 53,
        targetPort: 'dns',
      },
      {
        name: 'dns-tcp',
        protocol: 'TCP',
        port: 53,
        targetPort: 'dns',
      },
      {
        name: 'dns-over-tls',
        protocol: 'TCP',
        port: 853,
        targetPort: 'dns-over-tls',
      },
      {
        name: 'dns-over-https',
        protocol: 'TCP',
        port: 443,
        targetPort: 'dns-over-https',
      },
    ],
    loadBalancerIP: '192.168.0.135',
    type: 'LoadBalancer',
  },
}
