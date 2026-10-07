local app = import 'app.json5';

local appSelector = {
  'k8s:io.kubernetes.pod.namespace': app.namespace,
  'k8s:app.kubernetes.io/instance': app.name,
};
local component(name) = appSelector {
  'k8s:app.kubernetes.io/name': app.name + '-' + name,
};
local selector(name) = { matchLabels: name };
local ports(values) = [
  { port: std.toString(value), protocol: 'TCP' }
  for value in values
];
local from(name, portValues) = {
  fromEndpoints: [{ matchLabels: name }],
  toPorts: [{ ports: ports(portValues) }],
};
local to(name, portValues) = {
  toEndpoints: [{ matchLabels: name }],
  toPorts: [{ ports: ports(portValues) }],
};
local dns = {
  toEndpoints: [{
    matchLabels: {
      'k8s:io.kubernetes.pod.namespace': 'kube-system',
      'k8s:k8s-app': 'kube-dns',
    },
  }],
  toPorts: [{
    ports: [
      { port: '53', protocol: 'UDP' },
      { port: '53', protocol: 'TCP' },
    ],
    rules: {
      dns: [{ matchPattern: '*' }],
    },
  }],
};
local envoy = {
  'k8s:io.kubernetes.pod.namespace': 'envoy-gateway-system',
  'k8s:app.kubernetes.io/component': 'proxy',
  'k8s:app.kubernetes.io/managed-by': 'envoy-gateway',
  'k8s:app.kubernetes.io/name': 'envoy',
};
local seaweedS3 = {
  'k8s:io.kubernetes.pod.namespace': 'seaweedfs',
  'k8s:app.kubernetes.io/component': 's3',
  'k8s:app.kubernetes.io/instance': 'seaweedfs-default',
  'k8s:app.kubernetes.io/name': 'seaweedfs',
};
local postgres = {
  'k8s:io.kubernetes.pod.namespace': 'databases',
  'k8s:cnpg.io/cluster': 'postgresql-default',
  'k8s:cnpg.io/instanceRole': 'primary',
};
local monitoring = {
  'k8s:io.kubernetes.pod.namespace': 'opentelemetry-collector',
  'k8s:app.kubernetes.io/name': 'prometheus-collector',
  'k8s:app.kubernetes.io/instance': 'opentelemetry-collector.prometheus',
};
local fqdn(name, port) = {
  toFQDNs: [{ matchName: name }],
  toPorts: [{ ports: ports([port]) }],
};
local policy(name, endpoint, ingress, egress) = {
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-' + name,
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: selector(endpoint),
    ingress: ingress,
    egress: egress,
  },
};

[
  policy(
    'frontend',
    component('frontend'),
    [from(envoy, [8080])],
    [
      dns,
      to(component('backend'), [6060]),
      to(component('exporter'), [6061]),
      to(component('mcp'), [4401, 4402]),
    ],
  ),
  policy(
    'backend',
    component('backend'),
    [
      from(component('frontend'), [6060]),
      from(monitoring, [6060]),
    ],
    [
      dns,
      to(postgres, [5432]),
      to(component('valkey'), [6379]),
      to(seaweedS3, [8333]),
      fqdn('penpot.seaweedfs.walnuts.dev', 443),
      fqdn('auth.walnuts.dev', 443),
    ],
  ),
  policy(
    'exporter',
    component('exporter'),
    [from(component('frontend'), [6061])],
    [
      dns,
      to(component('frontend'), [8080]),
      to(component('valkey'), [6379]),
    ],
  ),
  policy(
    'mcp',
    component('mcp'),
    [
      from(component('frontend'), [4401]),
      from(component('frontend'), [4402]),
    ],
    [dns, to(component('valkey'), [6379])],
  ),
  policy(
    'valkey',
    component('valkey'),
    [
      from(component('backend'), [6379]),
      from(component('exporter'), [6379]),
      from(component('mcp'), [6379]),
    ],
    [dns],
  ),
]
