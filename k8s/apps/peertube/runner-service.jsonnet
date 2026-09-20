local app = import 'app.json5';
local labels = {
  'app.kubernetes.io/name': app.name,
  'app.kubernetes.io/instance': app.name,
  'app.kubernetes.io/part-of': app.name,
  'app.kubernetes.io/component': 'runner',
};
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-runner-headless',
    namespace: app.namespace,
  },
  spec: {
    clusterIP: 'None',
    publishNotReadyAddresses: true,
    selector: labels { 'peertube.runner/group': 'vod' },
  },
}
