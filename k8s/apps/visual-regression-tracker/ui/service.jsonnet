local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local appname = app.name + '-ui';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: appname,
    namespace: app.namespace,
    labels: labels(appname),
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 8080,
        targetPort: 8080,
      },
    ],
    selector: labels(appname),
    type: 'ClusterIP',
  },
}
