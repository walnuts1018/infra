(import '../../components/pomerium-oidc-filter/policy-filter.libsonnet') {
  name: (import 'app.json5').name,
  namespace: 'monitoring',
  allowedGroup: '356681781363081691:hubble-admin',
}
