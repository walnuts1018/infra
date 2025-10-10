{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    selector: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
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
