local gateway = import 'gateway.jsonnet';
{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'ClientTrafficPolicy',
  metadata: {
    name: 'enable-http3',
    namespace: gateway.metadata.namespace,
  },
  spec: {
    http3: {},
    targetRefs: [
      {
        group: 'gateway.networking.k8s.io',
        kind: 'Gateway',
        name: gateway.metadata.name,
      },
    ],
  },
}
