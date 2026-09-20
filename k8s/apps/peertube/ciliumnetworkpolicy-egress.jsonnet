local app = import 'app.json5';
local deployment = import 'deployment.jsonnet';
local valkeyCluster = import 'valkeycluster.jsonnet';
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
        'k8s:app.kubernetes.io/name': deployment.metadata.labels['app.kubernetes.io/name'],
        'k8s:app.kubernetes.io/component': deployment.metadata.labels['app.kubernetes.io/component'],
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
        toPorts: [{
          ports: [
            {
              port: '53',
              protocol: 'UDP',
            },
            {
              port: '53',
              protocol: 'TCP',
            },
          ],
          rules: {
            dns: [
              {
                matchPattern: '*',
              },
            ],
          },
        }],
      },
      {
        toEndpoints: [
          {
            matchLabels: {
              'k8s:io.kubernetes.pod.namespace': 'databases',
              'k8s:cnpg.io/cluster': 'postgresql-default',
              'k8s:cnpg.io/instanceRole': 'primary',
            },
          },
        ],
        toPorts: [
          {
            ports: [
              {
                port: '5432',
                protocol: 'TCP',
              },
            ],
          },
        ],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': app.namespace,
            'k8s:valkey.io/cluster': valkeyCluster.metadata.name,
          },
        }],
        toPorts: [
          {
            ports: [
              {
                port: '6379',
                protocol: 'TCP',
              },
            ],
          },
        ],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'seaweedfs',
            'k8s:app.kubernetes.io/component': 'filer',
            'k8s:app.kubernetes.io/instance': 'seaweedfs-default',
          },
        }],
        toPorts: [
          {
            ports: [
              {
                port: '8333',
                protocol: 'TCP',
              },
            ],
          },
        ],
      },
    ],
  },
}
