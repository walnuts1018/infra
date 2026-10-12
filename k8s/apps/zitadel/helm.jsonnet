local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,

  chart: 'zitadel',
  repoURL: 'https://charts.zitadel.com',
  targetRevision: '10.4.0',
  valuesObject: std.mergePatch(std.parseYaml(importstr 'values.yaml'), {
    extraManifests: [
      std.parseYaml(importstr 'config/network-policy.yaml'),
      std.parseYaml(importstr 'config/network-policy-ingress.yaml'),
      std.parseYaml(importstr 'config/network-policy-bootstrap-egress.yaml'),
    ],
  }),
}
