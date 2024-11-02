{
  name:: error 'name is required',
  data:: error 'data is required',
  apiVersion: 'external-secrets.io/v1beta1',
  kind: 'ExternalSecret',
  metadata: {
    name: $.name,
  },
  spec: {
    secretStoreRef: {
      name: 'onepassword',
      kind: 'ClusterSecretStore',
    },
    refreshInterval: '1m',
    target: {
      name: $.name,
    },
    data: $.data,
  },
}
