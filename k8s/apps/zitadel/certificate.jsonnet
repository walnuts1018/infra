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
      // SystemAPIUsersとLogin UIの鍵を同時に変更しないよう、更新時も秘密鍵を維持する。
      rotationPolicy: 'Never',
    },
    issuerRef: {
      name: 'selfsigned',
      kind: 'ClusterIssuer',
      group: 'cert-manager.io',
    },
  },
}
