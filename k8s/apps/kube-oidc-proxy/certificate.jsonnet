local issuer = import '../clusterissuer/local-issuer.jsonnet';
local app = import 'app.json5';
local service = import 'service.jsonnet';

{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    dnsNames: [
      service.metadata.name,
      service.metadata.name + '.' + service.metadata.namespace,
      service.metadata.name + '.' + service.metadata.namespace + '.svc',
      service.metadata.name + '.' + service.metadata.namespace + '.svc.cluster.local',
    ],
    issuerRef: {
      group: 'cert-manager.io',
      kind: issuer.kind,
      name: issuer.metadata.name,
    },
    secretName: app.name + '-tls',
    usages: ['server auth'],
  },
}
