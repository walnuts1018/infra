local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-etcd',
    namespace: app.namespace,
    labels: labels('coredns-etcd'),
  },
  spec: {
    selector: labels('coredns-etcd'),
    ports: [
      {
        name: 'client',
        port: 2379,
        targetPort: 'client',
      },
    ],
  },
}
