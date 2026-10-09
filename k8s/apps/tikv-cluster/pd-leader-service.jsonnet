local app = import 'app.json5';
local workloadLabels = {
  'app.kubernetes.io/name': 'pd-leader-prober',
  'app.kubernetes.io/instance': app.name,
};

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-pd-leader-prober',
    namespace: app.namespace,
    labels: workloadLabels,
  },
  spec: {
    selector: workloadLabels,
    ports: [
      {
        name: 'http',
        port: 9115,
        targetPort: 'http',
        protocol: 'TCP',
      },
    ],
  },
}
