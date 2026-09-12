local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name) + {
      'app.kubernetes.io/component': 'mini',
    },
  },
  spec: {
    type: 'ClusterIP',
    clusterIP: 'None',
    selector: labels(app.name) + {
      'app.kubernetes.io/component': 'mini',
    },
    ports: [
      {
        name: 's3',
        port: 8333,
        targetPort: 's3',
        protocol: 'TCP',
      },
    ],
  },
}
