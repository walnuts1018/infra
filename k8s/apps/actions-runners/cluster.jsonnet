local app = import 'app.json5';
local kubeconfigSecret = import 'rusk-kubeconfig.jsonnet';

{
  apiVersion: 'sharc.walnuts.dev/v1alpha1',
  kind: 'RunnerCluster',
  metadata: {
    name: 'rusk',
    namespace: app.namespace,
  },
  spec: {
    kubeconfigSecretRef: {
      name: kubeconfigSecret.spec.target.name,
      key: 'kubeconfig',
    },
    runnerNamespace: 'gha-runners',
    startup: {
      machineRefs: [
        { name: 'rusk' },
      ],
    },
    readiness: {
      apiRequestTimeout: '5s',
      nodeReadyTimeout: '10m',
    },
  },
}
