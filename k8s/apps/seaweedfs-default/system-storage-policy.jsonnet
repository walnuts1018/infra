local app = import 'app.json5';
{
  apiVersion: 'seaweed.seaweedfs.com/v1',
  kind: 'AdminScript',
  metadata: {
    name: 'system-storage-policy',
    namespace: app.namespace,
  },
  spec: {
    clusterRef: {
      name: app.name,
    },
    schedule: '0 3 * * *',
    concurrencyPolicy: 'Forbid',
    script: |||
      fs.configure -locationPrefix=/ -disk=ssd -replication=001 -apply
      fs.configure -locationPrefix=/topics/.system/ -disk=ssd -replication=001 -apply
    |||,
  },
}
