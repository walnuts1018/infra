local app = import 'app.json5';
{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-egress',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: {
        'k8s:app': app.name,
        'k8s:app.kubernetes.io/name': app.name,
      },
    },
    egress: [
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'kube-system',
            'k8s:k8s-app': 'kube-dns',
          },
        }],
        toPorts: [{ ports: [
          { port: '53', protocol: 'UDP' },
          { port: '53', protocol: 'TCP' },
        ] }],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'databases',
            'k8s:cnpg.io/cluster': 'postgresql-default',
            'k8s:cnpg.io/instanceRole': 'primary',
          },
        }],
        toPorts: [{ ports: [{ port: '5432', protocol: 'TCP' }] }],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': app.namespace,
            'k8s:valkey.io/cluster': app.name + '-valkey',
          },
        }],
        toPorts: [{ ports: [{ port: '6379', protocol: 'TCP' }] }],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': app.namespace,
            'k8s:common.k8s.elastic.co/type': 'elasticsearch',
            'k8s:elasticsearch.k8s.elastic.co/cluster-name': app.name,
          },
        }],
        toPorts: [{ ports: [{ port: '9200', protocol: 'TCP' }] }],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'seaweedfs',
            'k8s:app.kubernetes.io/component': 's3',
            'k8s:app.kubernetes.io/instance': 'seaweedfs-default',
            'k8s:app.kubernetes.io/name': 'seaweedfs',
          },
        }],
        toPorts: [{ ports: [{ port: '8333', protocol: 'TCP' }] }],
      },
      {
        // The S3 endpoint uses the HTTPS route served by Envoy Gateway.
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'envoy-gateway-system',
            'k8s:app.kubernetes.io/component': 'proxy',
            'k8s:app.kubernetes.io/managed-by': 'envoy-gateway',
            'k8s:app.kubernetes.io/name': 'envoy',
          },
        }],
        toPorts: [{ ports: [{ port: '443', protocol: 'TCP' }] }],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'opentelemetry-collector',
            'k8s:app.kubernetes.io/instance': 'opentelemetry-collector.default',
            'k8s:app.kubernetes.io/name': 'default-collector',
          },
        }],
        toPorts: [{ ports: [{ port: '4317', protocol: 'TCP' }] }],
      },
      {
        toEntities: ['world'],
        toPorts: [{ ports: [{ port: '25', protocol: 'TCP' }] }],
      },
    ],
  },
}
