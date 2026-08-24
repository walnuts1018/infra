local app = import 'app.json5';
local redfishSecret = import 'rusk-redfish.jsonnet';
{
  apiVersion: 'gha.walnuts.dev/v1alpha1',
  kind: 'RunnerMachine',
  metadata: {
    name: 'rusk',
    namespace: app.namespace,
  },
  spec: {
    clusterRef: {
      name: (import 'cluster.jsonnet').metadata.name,
    },
    nodePoolRef: {
      name: (import 'nodepool.jsonnet').metadata.name,
    },
    nodeName: 'rusk',
    powerPolicy: 'OnDemand',
    capacity: {
      runnerSlots: 11,
    },
    priority: 100,
    redfish: {
      endpoint: 'https://192.168.4.101/',
      credentialsSecretRef: {
        name: redfishSecret.spec.target.name,
      },
      tls: {
        insecureSkipVerify: true,
      },
      power: {
        shutdown: {
          timeout: '3m',
          timeoutPolicy: 'Abort',
        },
      },
    },
    drain: {
      timeout: '10m',
    },
  },
}
