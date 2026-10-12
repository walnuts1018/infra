local app = import 'app.json5';
local workloadLabels = {
  'app.kubernetes.io/name': 'pd-leader-prober',
  'app.kubernetes.io/instance': app.name,
};

{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-pd-leader-prober',
    namespace: app.namespace,
    labels: workloadLabels,
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: workloadLabels,
    },
    template: {
      metadata: {
        labels: workloadLabels,
      },
      spec: {
        securityContext: {
          fsGroup: 1000,
          fsGroupChangePolicy: 'OnRootMismatch',
          seccompProfile: { type: 'RuntimeDefault' },
        },
        containers: [
          {
            name: 'blackbox-exporter',
            image: 'quay.io/prometheus/blackbox-exporter:v0.29.0@sha256:c827aebdb688c29f3472bdfacff50c7c1e243ddfa3a7de76db41706d64646479',
            args: ['--config.file=/etc/blackbox/blackbox.yml'],
            ports: [
              {
                name: 'http',
                containerPort: 9115,
                protocol: 'TCP',
              },
            ],
            resources: {
              requests: {
                cpu: '50m',
                memory: '64Mi',
              },
              limits: {
                cpu: '50m',
                memory: '64Mi',
              },
            },
            securityContext: {
              runAsNonRoot: true,
              runAsUser: 1000,
              runAsGroup: 1000,
              allowPrivilegeEscalation: false,
              readOnlyRootFilesystem: true,
              capabilities: { drop: ['ALL'] },
            },
            volumeMounts: [
              {
                name: 'config',
                mountPath: '/etc/blackbox',
                readOnly: true,
              },
              {
                name: 'pd-client-tls',
                mountPath: '/etc/pd-client-tls',
                readOnly: true,
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'config',
            configMap: {
              name: app.name + '-pd-leader-prober',
            },
          },
          {
            name: 'pd-client-tls',
            secret: {
              secretName: 'tikv-cluster-pd-cluster-secret',
              defaultMode: 288,
            },
          },
        ],
      },
    },
  },
}
