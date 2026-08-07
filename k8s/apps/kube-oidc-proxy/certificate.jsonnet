local issuer = import '../clusterissuer/local-issuer.jsonnet';
local app = import 'app.json5';

{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    dnsNames: [
      app.name,
      app.name + '.' + app.namespace,
      app.name + '.' + app.namespace + '.svc',
      app.name + '.' + app.namespace + '.svc.cluster.local',
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
