{
  name:: error 'name is required',
  namespace:: '',
  use_suffix:: true,
  data:: error 'data is required',
  template_data:: null,
  type:: 'Opaque',
  apiVersion: 'external-secrets.io/v1',
  kind: 'ExternalSecret',
  metadata: {
    name: $.name + if $.use_suffix then '-' + std.md5(
      std.toString($.data) + std.toString($.template_data),
    )[0:6] else '',
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
      template: {
        engineVersion: 'v2',
        type: $.type,
        [if $.template_data != null then 'data']: $.template_data,
      },
    },
    data: $.data,
  },
}
