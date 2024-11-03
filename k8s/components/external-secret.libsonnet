{
  name:: error 'name is required',
  use_suffix:: true,
  data:: error 'data is required',
  apiVersion: 'external-secrets.io/v1beta1',
  kind: 'ExternalSecret',
  metadata: {
    name: if $.use_suffix then $.name + '-' + std.md5(std.toString($.data) + { spec: { target: { name: null } } })[0:6] else $.name,
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
