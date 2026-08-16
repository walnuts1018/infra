local app = import 'app.json5';
{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {},
    ingress: [
      {
        fromEndpoints: [
          {
            matchLabels: {
              'io.kubernetes.pod.namespace': 'opentelemetry-collector',
            },
          },
        ],
        toPorts: [
          {
            ports: [
              {
                port: '8080',
                protocol: 'TCP',
              },
            ],
          },
        ],
      },
    ],
    egress: [
      {
        toCIDRSet: [
          {
            cidr: '0.0.0.0/0',
            except: [
              '192.168.0.0/16',
              '10.244.0.0/16',
              '10.96.0.0/12',
            ],
          },
        ],
      },
      {
        toEndpoints: [
          {
            matchLabels: {
              'io.kubernetes.pod.namespace': 'kube-system',
              'k8s-app': 'kube-dns',
            },
          },
        ],
        toPorts: [
          {
            ports: [
              {
                port: '53',
                protocol: 'ANY',
              },
            ],
            rules: {
              dns: [
                {
                  matchPattern: '*',
                },
              ],
            },
          },
        ],
      },
      {
        toEndpoints: [
          {
            matchLabels: {
              'io.kubernetes.pod.namespace': 'arc-systems',
              'app.kubernetes.io/name': 'github-actions-cache-server',
            },
          },
        ],
        toPorts: [
          {
            ports: [
              {
                port: '3000',
                protocol: 'TCP',
              },
            ],
          },
        ],
      },
      {
        toEndpoints: [
          {
            matchLabels: {
              'io.kubernetes.pod.namespace': 'seaweedfs',
              'app.kubernetes.io/name': 'seaweedfs',
              'app.kubernetes.io/component': 'filer',
            },
          },
        ],
        toPorts: [
          {
            ports: [
              {
                port: '8333',
                protocol: 'TCP',
              },
            ],
            rules: {
              http: [
                {
                  path: '^/gha-cache/.*',
                },
              ],
            },
          },
        ],
      },
    ],
  },
}
