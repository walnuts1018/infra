local app = import 'app.json5';

{
  apiVersion: 'keda.sh/v1alpha1',
  kind: 'ScaledObject',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    scaleTargetRef: {
      name: app.name,
    },
    minReplicaCount: 0,
    maxReplicaCount: 2,
    cooldownPeriod: 300,
    triggers: [
      {
        type: 'external-push',
        metadata: {
          scalerAddress: 'keda-add-ons-http-external-scaler.keda:9090',
          interceptorRoute: app.name,
        },
      },
    ],
  },
}
