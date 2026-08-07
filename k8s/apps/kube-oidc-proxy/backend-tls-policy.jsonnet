local app = import 'app.json5';
local service = import 'service.jsonnet';

{
  apiVersion: 'gateway.networking.k8s.io/v1alpha3',
  kind: 'BackendTLSPolicy',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    targetRefs: [
      {
        group: '',
        kind: service.kind,
        name: service.metadata.name,
      },
    ],
    validation: {
      caCertificateRefs: [
        {
          group: '',
          kind: 'ConfigMap',
          name: 'local-ca-bundle',
        },
      ],
      hostname: app.name + '.' + app.namespace + '.svc.cluster.local',
    },
  },
}
