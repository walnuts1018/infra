local app = import 'app.json5';
local s3 = import 's3-resources.libsonnet';
(import '../../components/external-secret.libsonnet') {
  name: app.name + '-s3-credentials',
  namespace: app.namespace,
  data: [
    {
      secretKey: identity.name + '_secretkey',
      remoteRef: {
        key: 'seaweedfs',
        property: identity.name + '_secretkey',
      },
    }
    for identity in s3.identities
  ],
  template_data: std.foldl(
    function(data, identity)
      data {
        [identity.name + '_accesskey']: identity.name,
        [identity.name + '_secretkey']: '{{ .' + identity.name + '_secretkey }}',
      },
    s3.identities,
    {}
  ),
}
