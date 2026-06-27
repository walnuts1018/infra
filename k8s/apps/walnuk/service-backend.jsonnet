local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.appname.backend,
    namespace: app.namespace,
    labels: (labels)(app.appname.backend),
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 8080,
        targetPort: 8080,
      },
    ],
    selector: (labels)(app.appname.backend),
    type: 'ClusterIP',
  },
}
