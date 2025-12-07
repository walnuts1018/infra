{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import 'app.json5').name + '-rw-expose',
    namespace: (import 'app.json5').namespace,
    labels: {
      'cnpg.io/cluster': 'postgresql-default',
    },
  },
  spec: {
    selector: {
      'cnpg.io/cluster': 'postgresql-default',
      'cnpg.io/instanceRole': 'primary',
    },
    ports: [
      {
        name: 'postgres',
        protocol: 'TCP',
        port: 5432,
        targetPort: 5432,
      },
    ],
    type: 'LoadBalancer',
    loadBalancerIP: '192.168.0.141',
  },
}
