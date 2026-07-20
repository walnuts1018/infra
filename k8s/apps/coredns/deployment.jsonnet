local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
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
          std.mergePatch((import '../../components/container.libsonnet'), {
            name: 'coredns',
            resizePolicy: [
              {
                resourceName: 'cpu',
                restartPolicy: 'NotRequired',
              },
              {
                resourceName: 'memory',
                restartPolicy: 'RestartContainer',
              },
            ],
            image: 'coredns/coredns:1.14.6',
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
                cpu: '5m',
                memory: '128Mi',
              },
              limits: {
                cpu: '500m',
                memory: '256Mi',
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
              name: (import 'configmap.jsonnet').metadata.name,
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
