local app = import 'app.json5';

local endpoint = function(namespace, labels) {
  matchLabels: {
    'k8s:io.kubernetes.pod.namespace': namespace,
  } + labels,
};

local scyllaNodes = endpoint(app.namespace, {
  'k8s:scylla/cluster': app.name,
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
    endpointSelector: scyllaNodes,
    ingress: [
      {
        // ノード間ストリーミングには動的ポートも使われるため、接続元を同一クラスターに限定してTCP全ポートを許可する。
        fromEndpoints: [scyllaNodes],
        toPorts: [{ ports: [{ port: '1', endPort: 65535, protocol: 'TCP' }] }],
      },
      {
        fromEndpoints: [
          endpoint('picca', { 'k8s:app.kubernetes.io/name': 'picca-apiserver' }),
          endpoint('prfexample', { 'k8s:app.kubernetes.io/name': 'prfexample' }),
          endpoint('walnuk', { 'k8s:app.kubernetes.io/name': 'walnuk-backend' }),
          endpoint(app.namespace, { 'k8s:app': app.name + '-setup' }),
        ],
        toPorts: [{ ports: [{ port: '9142', protocol: 'TCP' }] }],
      },
      {
        fromEndpoints: [endpoint('scylla-manager', {
          'k8s:app.kubernetes.io/instance': 'scylla-manager',
          'k8s:app.kubernetes.io/name': 'scylla-manager',
        })],
        toPorts: [{ ports: [
          { port: '9042', protocol: 'TCP' },
          { port: '10001', protocol: 'TCP' },
        ] }],
      },
      {
        fromEndpoints: [prometheusCollector],
        toPorts: [{ ports: [
          { port: '5090', protocol: 'TCP' },
          { port: '9180', protocol: 'TCP' },
        ] }],
      },
      {
        fromEntities: ['host'],
        toPorts: [{ ports: [
          { port: '8080', protocol: 'TCP' },
          { port: '9100', protocol: 'TCP' },
          { port: '10001', protocol: 'TCP' },
          { port: '42081', protocol: 'TCP' },
        ] }],
      },
    ],
  },
}
