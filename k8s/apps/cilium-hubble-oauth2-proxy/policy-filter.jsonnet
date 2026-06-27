local app = import 'app.json5';
(import '../../components/pomerium-oidc-filter/policy-filter.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  allowedGroup: '356681781363081691:hubble-user',
}
