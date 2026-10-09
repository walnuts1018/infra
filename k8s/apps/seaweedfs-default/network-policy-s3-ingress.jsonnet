local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';

local peer(namespace, podSelector) = {
  namespaceSelector: {
    matchLabels: {
      'kubernetes.io/metadata.name': namespace,
    },
  },
  podSelector: podSelector,
};
local filerPeer = peer(app.namespace, {
  matchLabels: {
    'app.kubernetes.io/component': 'filer',
    'app.kubernetes.io/instance': app.name,
    'app.kubernetes.io/managed-by': 'seaweedfs-operator',
    'app.kubernetes.io/name': 'seaweedfs',
  },
});

// Piccaのegress許可とこのIngress許可に同じcomponent名を使う。
local piccaS3ClientNames = [
  'picca-apiserver',
  'picca-imgproxy',
  'picca-dense-service',
  'picca-dense-worker',
  'picca-caption-worker',
  'picca-ocr-worker',
  'picca-ocr-vl-worker',
  'picca-download-worker',
  'picca-embedding-worker',
  'picca-empty-trash-worker',
  'picca-image-processing-worker',
  'picca-index-commit-worker',
  'picca-storage-reconciler',
  'picca-video-processing-worker',
  'picca-video-transcode-worker',
];

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-s3-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/component': 's3',
        'app.kubernetes.io/instance': app.name,
        'app.kubernetes.io/managed-by': 'seaweedfs-operator',
        'app.kubernetes.io/name': 'seaweedfs',
      },
    },
    policyTypes: ['Ingress'],
    ingress: [
      {
        from: [
          networkPolicy.envoyGatewayProxy,
          peer('beast', { matchLabels: { 'app.kubernetes.io/name': 'backend' } }),
          peer('beast', { matchLabels: { 'app.kubernetes.io/name': 'encoder' } }),
          peer('ipu', { matchLabels: { 'app.kubernetes.io/name': 'ipu' } }),
          peer('maps', { matchLabels: { 'app.kubernetes.io/name': 'maps-versatiles-server' } }),
          peer('maps', { matchLabels: { 'app.kubernetes.io/name': 'maps-update' } }),
          peer('penpot', { matchLabels: { 'app.kubernetes.io/name': 'penpot-backend' } }),
          peer('penpot', { matchLabels: { 'app.kubernetes.io/name': 'penpot-frontend' } }),
          peer('picca', {
            matchExpressions: [
              {
                key: 'app.kubernetes.io/name',
                operator: 'In',
                values: piccaS3ClientNames,
              },
            ],
          }),
          peer('stalwart', { matchLabels: { 'app.kubernetes.io/name': 'stalwart' } }),
        ],
        ports: [{ protocol: 'TCP', port: 8333 }],
      },
      {
        from: [networkPolicy.otelPrometheusCollector],
        ports: [{ protocol: 'TCP', port: 9327 }],
      },
      {
        from: [filerPeer],
        ports: [{ protocol: 'TCP', port: 18333 }],
      },
    ],
  },
}
