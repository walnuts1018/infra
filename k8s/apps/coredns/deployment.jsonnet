local container = import '../../components/container.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local configmap = import 'configmap.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (labels)(app.name),
    },
    template: {
      metadata: {
        labels: (labels)(app.name),
      },
      spec: {
        containers: [
          std.mergePatch((container), {
            name: 'coredns',
            image: 'coredns/coredns:1.14.4',
            args: [
              '-conf',
              '/etc/coredns/Corefile',
            ],
            ports: [
              {
                name: 'dns',
                containerPort: 53,
                protocol: 'UDP',
              },
              {
                name: 'dns-tcp',
                containerPort: 53,
                protocol: 'TCP',
              },
              {
                name: 'dns-over-tls',
                containerPort: 853,
                protocol: 'TCP',
              },
              {
                name: 'dns-over-https',
                containerPort: 443,
                protocol: 'TCP',
              },
              {
                name: 'metrics',
                containerPort: 9153,
                protocol: 'TCP',
              }
              {
                name: 'liveness-probe',
                containerPort: 8080,
                protocol: 'TCP',
              },
              {
                name: 'readiness-probe',
                containerPort: 8181,
                protocol: 'TCP',
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/health',
                port: 'liveness-probe',
              },
            },
            readinessProbe: {
              httpGet: {
                path: '/ready',
                port: 'readiness-probe',
              },
            },
            securityContext: {
              allowPrivilegeEscalation: false,
            },
            resources: {
              requests: {
                cpu: '1m',
                memory: '64Mi',
              },
              limits: {
                cpu: '500m',
                memory: '512Mi',
              },
            },
            volumeMounts: [
              {
                name: 'corefile',
                mountPath: '/etc/coredns',
                readOnly: true,
              },
            ],
          }),
        ],
        volumes: [
          {
            name: 'corefile',
            configMap: {
              name: configmap.metadata.name,
            },
          },
        ],
        affinity: {
          podAntiAffinity: {
            preferredDuringSchedulingIgnoredDuringExecution: [
              {
                weight: 100,
                podAffinityTerm: {
                  labelSelector: {
                    matchExpressions: [
                      {
                        key: 'app',
                        operator: 'In',
                        values: [
                          app.name,
                        ],
                      },
                    ],
                  },
                  topologyKey: 'kubernetes.io/hostname',
                },
              },
            ],
          },
        },

      },
    },
  },
}
