local app = import '../app.json5';
local worker = import 'stack-timeline-worker.jsonnet';
{
  apiVersion: 'keda.sh/v1alpha1',
  kind: 'ScaledObject',
  metadata: { name: worker.metadata.name, namespace: app.namespace },
  spec: {
    pollingInterval: 5,
    minReplicaCount: 0,
    maxReplicaCount: 8,
    scaleTargetRef: { name: worker.metadata.name },
    triggers: [{
      type: 'rabbitmq',
      metricType: 'Value',
      metadata: { protocol: 'http', queueName: 'picca.stack-timeline', mode: 'QueueLength', value: '1' },
      authenticationRef: { name: app.name + '-rabbitmq-worker-auth' },
    }],
  },
}
