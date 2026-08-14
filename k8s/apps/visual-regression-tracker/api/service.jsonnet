local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local appname = app.name + '-api';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: appname,
    namespace: app.namespace,
    labels: (labels)(appname),
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 4200,
        targetPort: 4200,
      },
    ],
    selector: (labels)(appname),
    type: 'ClusterIP',
  },
}
