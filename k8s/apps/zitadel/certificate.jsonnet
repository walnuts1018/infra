local app = import 'app.json5';

{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'zitadel-login-service-key',
    namespace: app.namespace,
  },
  spec: {
    secretName: 'zitadel-login-service-key',
    commonName: 'login-service',
    duration: '87600h',
    privateKey: {
      algorithm: 'RSA',
      size: 2048,
      rotationPolicy: 'Never',
    },
    issuerRef: {
      name: 'selfsigned',
      kind: 'ClusterIssuer',
      group: 'cert-manager.io',
    },
  },
}
