local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.appname.frontend,
    namespace: app.namespace,
    labels: (labels)(app.appname.frontend),
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 3000,
        targetPort: 3000,
      },
    ],
    selector: (labels)(app.appname.frontend),
    type: 'ClusterIP',
  },
}
