(import '../../../components/pomerium-oidc-filter/policy-filter.libsonnet') {
  name: (import '../app.json5').name,
  namespace: (import '../app.json5').namespace,
  allowedGroup: '356681781363081691:oekaki-admin',
}
