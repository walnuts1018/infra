{
  name:: error 'name is required',
  namespace:: error 'namespace is required',
  use_suffix:: true,
  labels:: {},
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: $.name + if $.use_suffix then '-' + std.md5(std.toString($.data))[0:6] else '',
    namespace: $.namespace,
    labels: $.labels,
  },
  data: {},
}
