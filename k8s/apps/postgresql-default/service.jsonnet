local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-rw-expose',
    namespace: app.namespace,
    labels: {
      'cnpg.io/cluster': 'postgresql-default',
    },
    annotations: {
      'lbipam.cilium.io/ips': '192.168.12.141',
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
  },
}
