{
  name:: error 'name is required',
  namespace:: error 'namespace is required',
  labels:: {},
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: $.name + '-' + std.md5(std.toString($.data))[0:6],
    namespace: $.namespace,
    labels: $.labels,
  },
  data: {},
}
