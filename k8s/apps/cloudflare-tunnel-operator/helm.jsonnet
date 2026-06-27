local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
local externalSecret = import 'external-secret.jsonnet';
(helm) {
  name: app.name,
  namespace: app.namespace,

  chart: 'cloudflare-tunnel-operator',
  repoURL: 'https://walnuts1018.github.io/cloudflare-tunnel-operator/',
  targetRevision: '1.6.2',
  valuesObject: std.mergePatch(std.parseYaml(values), {
    cloudflareToken: {
      existingSecret: externalSecret.spec.target.name,
    },
  }),
}
