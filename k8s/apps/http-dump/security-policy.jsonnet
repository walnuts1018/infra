(import '../../components/envoy-oidc-filter/security-policy.libsonnet') {
  name: (import 'app.json5').name + '-oidc',
  namespace: (import 'app.json5').namespace,
  redirect_url: 'https://httptest.walnuts.dev/oauth2/callback',
  logout_path: '/logout',
  client_id: '341715627427299826',
  client_secret: {
    name: (import './external-secret-oidc.jsonnet').spec.target.name,
    key: 'client-secret',
  },
  targetRef: {
    group: 'gateway.networking.k8s.io',
    kind: 'HTTPRoute',
    name: (import 'httproute.jsonnet').metadata.name,
  },
}
