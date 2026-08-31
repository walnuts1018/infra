local zitadelKubernetesRbacApp = import '../zitadel-kubernetes-rbac/app.json5';
local app = import 'app.json5';

(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'radar',
  repoURL: 'https://skyhook-io.github.io/helm-charts',
  targetRevision: '1.12.2',
  valuesObject: std.mergePatch(std.parseYaml(importstr 'values.yaml'), {
    auth: {
      oidc: {
        scopes: [
          'openid',
          'email',
          'profile',
          'urn:zitadel:iam:org:project:id:' + zitadelKubernetesRbacApp.params.oidcIssuerAudience + ':aud',
        ],
      },
    },
  }),
}
