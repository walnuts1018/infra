local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local componentLabels = labels(app.name) + {
  'app.kubernetes.io/component': 'agent',
};
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: componentLabels,
    annotations: {
      'reloader.stakater.com/auto': 'true',
    },
  },
  spec: {
    replicas: 1,
    strategy: {
      type: 'Recreate',
    },
    selector: {
      matchLabels: componentLabels,
    },
    template: {
      metadata: {
        labels: componentLabels,
      },
      spec: {
        automountServiceAccountToken: false,
        affinity: {
          nodeAffinity: {
            preferredDuringSchedulingIgnoredDuringExecution: [
              {
                weight: 100,
                preference: {
                  matchExpressions: [
                    {
                      key: 'kubernetes.io/hostname',
                      operator: 'In',
                      values: ['rusk'],
                    },
                  ],
                },
              },
              {
                weight: 50,
                preference: {
                  matchExpressions: [
                    {
                      key: 'kubernetes.io/hostname',
                      operator: 'In',
                      values: ['cake'],
                    },
                  ],
                },
              },
            ],
          },
        },
        securityContext: {
          seccompProfile: {
            type: 'RuntimeDefault',
          },
        },
        initContainers: [
          {
            name: 'check-seaweedfs-endpoints',
            image: 'curlimages/curl:8.16.0',
            command: ['sh', '-ec'],
            args: [
              |||
                for endpoint in \
                  https://seaweedfs.walnuts.dev/healthz \
                  https://seaweedfs-biscuit.local.walnuts.dev/healthz; do
                  curl --fail --silent --show-error --retry 60 --retry-delay 5 --connect-timeout 5 "$endpoint"
                done
              |||,
            ],
            securityContext: {
              allowPrivilegeEscalation: false,
              capabilities: {
                drop: ['ALL'],
              },
            },
            resources: {
              requests: {
                cpu: '10m',
                memory: '16Mi',
              },
              limits: {
                cpu: '100m',
                memory: '64Mi',
              },
            },
          },
        ],
        containers: [
          {
            name: 'terraform-cloud-agent',
            image: 'hashicorp/tfc-agent:1.29.0',
            imagePullPolicy: 'IfNotPresent',
            env: [
              {
                name: 'TFC_AGENT_TOKEN',
                valueFrom: {
                  secretKeyRef: {
                    name: app.name,
                    key: 'TFC_AGENT_TOKEN',
                  },
                },
              },
            ],
            securityContext: {
              allowPrivilegeEscalation: false,
              capabilities: {
                drop: ['ALL'],
              },
            },
            resources: {
              requests: {
                cpu: '100m',
                memory: '256Mi',
              },
              limits: {
                cpu: '1',
                memory: '1Gi',
              },
            },
          },
        ],
      },
    },
  },
}
