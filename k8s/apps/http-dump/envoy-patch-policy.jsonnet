(import '../../components/envoy-oidc-filter/envoy-patch-policy.libsonnet') {
  name: (import 'app.json5').name,
}
