{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    ports: [
      {
        port: 80,
        protocol: 'TCP',
        targetPort: 8080,
      },
    ],
    selector: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    type: 'LoadBalancer',
    loadBalancerIP: '192.168.0.130',
  },
}
