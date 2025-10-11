(import '../../components/envoy-oidc-filter/envoy-patch.libsonnet') {
  name: (import 'app.json5').name,
}
