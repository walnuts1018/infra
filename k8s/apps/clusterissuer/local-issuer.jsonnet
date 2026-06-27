local localCert = import 'local-cert.jsonnet';
{
  apiVersion: 'cert-manager.io/v1',
  kind: 'ClusterIssuer',
  metadata: {
    name: 'local',
  },
  spec: {
    ca: {
      secretName: localCert.spec.secretName,
    },
  },
}
