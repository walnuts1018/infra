local policyFilter = import '../../components/pomerium-oidc-filter/policy-filter.libsonnet';
local app = import 'app.json5';
(policyFilter) {
  name: app.name,
  namespace: app.namespace,
  allowedGroup: '356681781363081691:warrior-user',
}
