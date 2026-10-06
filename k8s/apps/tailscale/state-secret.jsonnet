local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: 'tailscale',
    namespace: app.namespace,
  },
  type: 'Opaque',
}
