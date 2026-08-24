local app = import 'app.json5';

{
  apiVersion: 'sharc.walnuts.dev/v1alpha1',
  kind: 'RunnerNodePool',
  metadata: {
    name: 'rusk',
    namespace: app.namespace,
  },
  spec: {
    clusterRef: {
      name: (import 'cluster.jsonnet').metadata.name,
    },
    drain: {
      timeout: '10m',
    },
    scaling: {
      minNodes: 0,
      maxNodes: 1,
      scaleDownDelay: '10m',
    },
  },
}
