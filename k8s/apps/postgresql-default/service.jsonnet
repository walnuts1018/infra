{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import 'app.json5').name,
    labels: {
      application: 'spilo',
      'cluster-name': 'default',
      'spilo-role': 'master',
      team: 'default',
    },
  },
  spec: {
    ports: [
      {
        name: 'postgresql',
        port: 5432,
        targetPort: 5432,
      },
    ],
    selector: {
      application: 'spilo',
      'cluster-name': 'default',
      'spilo-role': 'master',
      team: 'default',
    },
    type: 'LoadBalancer',
    loadBalancerIP: '192.168.0.134',
  },
}
