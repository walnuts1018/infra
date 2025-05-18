{
  name:: error 'name is required',
  namespace:: '',
  use_suffix:: true,
  data:: error 'data is required',
  apiVersion: 'external-secrets.io/v1',
  kind: 'ExternalSecret',
  metadata: {
    name: $.name + if $.use_suffix then '-' + std.md5(std.toString($.data) + { spec: { target: { name: null } } })[0:6] else '',
    [if !($.namespace == '') then 'namespace']: $.namespace,
  },
  spec: {
    secretStoreRef: {
      name: 'onepassword',
      kind: 'ClusterSecretStore',
    },
    refreshInterval: '1m',
    target: {
      name: $.metadata.name,
    },
    data: $.data,
  },
}
