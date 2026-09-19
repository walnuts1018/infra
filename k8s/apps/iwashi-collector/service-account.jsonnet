local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: { name: 'iwashi-collector', namespace: app.namespace },
  imagePullSecrets: [{ name: 'ghcr-login-secret' }],
  automountServiceAccountToken: false,
}
