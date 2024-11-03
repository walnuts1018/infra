{
  name:: error 'name is required',
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: $.name + '-' + std.md5(std.toString($.data))[0:6],
  },
}
