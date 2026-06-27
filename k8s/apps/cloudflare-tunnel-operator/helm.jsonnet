local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'cloudflare-tunnel-operator',
  repoURL: 'https://walnuts1018.github.io/cloudflare-tunnel-operator/',
  targetRevision: '1.6.2',
  valuesObject: std.mergePatch(std.parseYaml(importstr 'values.yaml'), {
    cloudflareToken: {
      existingSecret: (import 'external-secret.jsonnet').spec.target.name,
    },
  }),
}
