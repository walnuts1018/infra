(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'cloudflare-tunnel-operator',
  repoURL: 'https://walnuts1018.github.io/cloudflare-tunnel-operator/',
  targetRevision: '1.3.0',
  valuesObject: std.mergePatch(std.parseYaml(importstr 'values.yaml'), {
    cloudflareToken: {
      existingSecret: (import 'external-secret.jsonnet').spec.target.name,
    },
  }),
}
