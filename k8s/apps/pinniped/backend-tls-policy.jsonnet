local app = import 'app.json5';
local service = import 'service.jsonnet';

{
  apiVersion: 'gateway.networking.k8s.io/v1alpha3',
  kind: 'BackendTLSPolicy',
  metadata: {
    name: app.name + '-supervisor',
    namespace: app.namespace,
  },
  spec: {
    targetRefs: [
      {
        group: '',
        kind: 'Service',
        name: service.metadata.name,
        sectionName: service.spec.ports[0].name,
      },
    ],
    validation: {
      hostname: 'kurumi-pinniped.local.walnuts.dev',
      wellKnownCACertificates: 'System',
    },
  },
}
