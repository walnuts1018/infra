function(app)
  local networkPolicy = import '../../network-policy.libsonnet';
  local peer = function(namespace, labels) {
    namespaceSelector: {
      matchLabels: {
        'kubernetes.io/metadata.name': namespace,
      },
    },
    podSelector: {
      matchLabels: labels,
    },
  };
  local localPeer = function(labels) {
    podSelector: {
      matchLabels: labels,
    },
  };
  local port = function(port) {
    protocol: 'TCP',
    port: port,
  };
  local egressRule = function(to, portNumber) {
    to: [to],
    ports: [port(portNumber)],
  };
  local ingressRule = function(from, portNumber) {
    from: from,
    ports: [port(portNumber)],
  };
  local dnsRule = {
    to: [networkPolicy.kubeDns],
    ports: [
      { protocol: 'UDP', port: 53 },
      { protocol: 'TCP', port: 53 },
    ],
  };
  local otelRule = egressRule(networkPolicy.otelDefaultCollector, 4318);
  local postgresRule = egressRule(peer('databases', {
    'cnpg.io/cluster': 'postgresql-default',
    'cnpg.io/instanceRole': 'primary',
  }), 5432);
  local scyllaRule = egressRule(peer('databases', { 'scylla/cluster': 'scylla-cluster' }), 9142);
  local valkeyRule = egressRule(localPeer({ 'valkey.io/cluster': app.name + '-valkey' }), 6379);
  local rabbitmqRule = egressRule(peer('rabbitmq', { 'app.kubernetes.io/name': 'default' }), 5672);
  local seaweedfsRule = egressRule(peer('seaweedfs', {
    'app.kubernetes.io/component': 's3',
    'app.kubernetes.io/instance': 'seaweedfs-default',
    'app.kubernetes.io/name': 'seaweedfs',
  }), 8333);
  local qdrantRule = egressRule(peer('qdrant', {
    'app.kubernetes.io/instance': 'qdrant',
    'app.kubernetes.io/name': 'qdrant',
  }), 6334);
  local denseServiceRule = egressRule(localPeer({ 'app.kubernetes.io/name': app.name + '-dense-service' }), 8001);
  local publicHttpsRule = {
    to: networkPolicy.publicInternet,
    ports: [port(443)],
  };
  local publicWebRule = {
    to: networkPolicy.publicInternet,
    ports: [port(80), port(443)],
  };
  local policy = function(component, dependencies) {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'NetworkPolicy',
    metadata: {
      name: app.name + '-egress-' + component,
      namespace: app.namespace,
    },
    spec: {
      podSelector: {
        matchLabels: {
          'app.kubernetes.io/name': app.name + '-' + component,
        },
      },
      policyTypes: ['Egress'],
      egress: [dnsRule] + dependencies,
    },
  };
  local ingressPolicy = function(component, rules) {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'NetworkPolicy',
    metadata: {
      name: app.name + '-ingress-' + component,
      namespace: app.namespace,
    },
    spec: {
      podSelector: {
        matchLabels: {
          'app.kubernetes.io/name': app.name + '-' + component,
        },
      },
      policyTypes: ['Ingress'],
      ingress: rules,
    },
  };
  [
    {
      apiVersion: 'networking.k8s.io/v1',
      kind: 'NetworkPolicy',
      metadata: {
        name: app.name + '-egress-default-deny',
        namespace: app.namespace,
      },
      spec: {
        podSelector: {},
        policyTypes: ['Egress'],
        egress: [],
      },
    },
    ingressPolicy('apiserver', [
      ingressRule([
        networkPolicy.envoyGatewayProxy,
        localPeer({ 'app.kubernetes.io/name': app.name + '-frontend' }),
      ], 8080),
    ]),
    ingressPolicy('imgproxy', [
      ingressRule([networkPolicy.envoyGatewayProxy], 8080),
      ingressRule([networkPolicy.otelPrometheusCollector], 8081),
    ]),
    policy('apiserver', [
      otelRule,
      postgresRule,
      scyllaRule,
      valkeyRule,
      rabbitmqRule,
      seaweedfsRule,
      qdrantRule,
      denseServiceRule,
      publicHttpsRule,
    ]),
    policy('frontend', [
      otelRule,
      egressRule(localPeer({ 'app.kubernetes.io/name': app.name + '-apiserver' }), 8080),
    ]),
    policy('imgproxy', [seaweedfsRule]),
    policy('dense-service', [seaweedfsRule]),
    policy('dense-worker', [rabbitmqRule, seaweedfsRule]),
    policy('caption-worker', [rabbitmqRule, seaweedfsRule]),
    policy('ocr-worker', [rabbitmqRule, seaweedfsRule]),
    policy('ocr-vl-worker', [rabbitmqRule, seaweedfsRule]),
    policy('download-worker', [
      otelRule,
      postgresRule,
      scyllaRule,
      valkeyRule,
      rabbitmqRule,
      seaweedfsRule,
      publicWebRule,
    ]),
    policy('embedding-worker', [
      otelRule,
      rabbitmqRule,
      seaweedfsRule,
      qdrantRule,
    ]),
    policy('empty-trash-worker', [
      otelRule,
      postgresRule,
      scyllaRule,
      rabbitmqRule,
      seaweedfsRule,
    ]),
    policy('image-processing-worker', [
      otelRule,
      postgresRule,
      scyllaRule,
      valkeyRule,
      rabbitmqRule,
      seaweedfsRule,
    ]),
    policy('index-commit-worker', [
      otelRule,
      postgresRule,
      rabbitmqRule,
      seaweedfsRule,
      qdrantRule,
    ]),
    policy('library-notify-worker', [
      otelRule,
      postgresRule,
      valkeyRule,
      rabbitmqRule,
    ]),
    policy('outbox-worker', [
      otelRule,
      postgresRule,
      rabbitmqRule,
    ]),
    policy('processing-reconciler', [
      otelRule,
      postgresRule,
    ]),
    policy('stack-timeline-worker', [
      otelRule,
      postgresRule,
      scyllaRule,
      valkeyRule,
      rabbitmqRule,
    ]),
    policy('storage-reconciler', [
      otelRule,
      postgresRule,
      seaweedfsRule,
    ]),
    policy('video-processing-worker', [
      otelRule,
      postgresRule,
      scyllaRule,
      valkeyRule,
      rabbitmqRule,
      seaweedfsRule,
    ]),
    policy('video-transcode-worker', [
      otelRule,
      rabbitmqRule,
      seaweedfsRule,
    ]),
    {
      apiVersion: 'networking.k8s.io/v1',
      kind: 'NetworkPolicy',
      metadata: {
        name: app.name + '-egress-valkey',
        namespace: app.namespace,
      },
      spec: {
        podSelector: {
          matchLabels: {
            'valkey.io/cluster': app.name + '-valkey',
          },
        },
        policyTypes: ['Egress'],
        egress: [
          dnsRule,
          egressRule(localPeer({ 'valkey.io/cluster': app.name + '-valkey' }), 6379),
          egressRule(localPeer({ 'valkey.io/cluster': app.name + '-valkey' }), 16379),
        ],
      },
    },
  ]
