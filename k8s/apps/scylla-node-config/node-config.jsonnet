{
  apiVersion: 'scylla.scylladb.com/v1alpha1',
  kind: 'NodeConfig',
  metadata: {
    name: 'default',
  },
  spec: {
    sysctls: [
      {
        name: 'fs.aio-max-nr',
        value: '30000000',
      },
    ],
    placement: {
      nodeSelector: {},
      tolerations: [],
    },
  },
}
