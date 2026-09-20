local app = import 'app.json5';
local runnerStatefulSet = import 'runner-statefulset.jsonnet';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: runnerStatefulSet.spec.serviceName,
    namespace: app.namespace,
  },
  spec: {
    clusterIP: 'None',
    publishNotReadyAddresses: true,
    selector: runnerStatefulSet.spec.selector.matchLabels,
  },
}
