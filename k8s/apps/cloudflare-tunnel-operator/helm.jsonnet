(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'actions-runner-controller',
  repoURL: 'https://walnuts1018.github.io/cloudflare-tunnel-operator/',
  targetRevision: '0.0.8',
  valuesObject: std.mergePatch(std.parseYaml, {
    cloudflareToken: {
      existingSecret: (import 'external-secret.jsonnet').spec.target.name,
    },
  }),
}
