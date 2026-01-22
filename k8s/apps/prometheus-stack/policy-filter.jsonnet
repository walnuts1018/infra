(import '../../components/pomerium-oidc-filter/policy-filter.libsonnet') {
  name: (import 'app.json5').name,
  namespace: 'monitoring',
  allowedGroup: '237477822715658605:prometheus-admin',
}
