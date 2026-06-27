local seaweedfsDefaultApp = import '../seaweedfs-default/app.json5';
local app = import 'app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1beta1',
  kind: 'ReferenceGrant',
  metadata: {
    name: app.name,
    namespace: seaweedfsDefaultApp.namespace,
  },
  spec: {
    from: [
      {
        group: 'gateway.networking.k8s.io',
        kind: 'HTTPRoute',
        namespace: app.namespace,
      },
    ],
    to: [
      {
        group: '',
        kind: 'Service',
      },
    ],
  },
}
