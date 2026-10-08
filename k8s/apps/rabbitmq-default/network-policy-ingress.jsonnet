local app = import 'app.json5';
local cluster = import 'rabbitmqcluster.jsonnet';
local endpoint = function(namespace, labels) {
  matchLabels: {
    'k8s:io.kubernetes.pod.namespace': namespace,
  } + labels,
};
local endpointForApp = function(namespace, name, component, instance)
  endpoint(namespace, {
    'k8s:app.kubernetes.io/component': component,
    'k8s:app.kubernetes.io/instance': instance,
    'k8s:app.kubernetes.io/name': name,
  });
local clientNamespaces = std.split(cluster.metadata.annotations['rabbitmq.com/topology-allowed-namespaces'], ',');
local rabbitmqEndpoint = endpoint(app.namespace, {
  'k8s:app.kubernetes.io/component': 'rabbitmq',
  'k8s:app.kubernetes.io/name': cluster.metadata.name,
});
local prometheusCollector = endpoint('opentelemetry-collector', {
  'k8s:app.kubernetes.io/component': 'opentelemetry-collector',
  'k8s:app.kubernetes.io/instance': 'opentelemetry-collector.prometheus',
});

{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-ingress',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: rabbitmqEndpoint,
    ingress: [
      {
        fromEndpoints: [endpoint(namespace, {}) for namespace in clientNamespaces],
        toPorts: [{ ports: [{ port: '5672', protocol: 'TCP' }] }],
      },
      {
        fromEntities: ['host'],
        toPorts: [{ ports: [{ port: '5672', protocol: 'TCP' }] }],
      },
      {
        fromEndpoints: [rabbitmqEndpoint],
        toPorts: [{ ports: [
          { port: '4369', protocol: 'TCP' },
          { port: '25672', protocol: 'TCP' },
        ] }],
      },
      {
        fromEndpoints: [
          endpointForApp('keda', 'keda-operator', 'operator', 'keda'),
          endpointForApp('rabbitmq-operator', 'rabbitmq-cluster-operator', 'rabbitmq-operator', 'rabbitmq-cluster-operator'),
          endpointForApp('rabbitmq-operator', 'rabbitmq-topology-operator', 'messaging-topology-operator', 'rabbitmq-topology-operator'),
        ],
        toPorts: [{ ports: [{ port: '15672', protocol: 'TCP' }] }],
      },
      {
        fromEndpoints: [prometheusCollector],
        toPorts: [{ ports: [{ port: '15692', protocol: 'TCP' }] }],
      },
    ],
  },
}
