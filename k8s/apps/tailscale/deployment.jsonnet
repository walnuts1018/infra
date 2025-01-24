{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    },
    template: {
      metadata: {
        annotations: {
          'k8s.v1.cni.cncf.io/networks': '[{"name": "tailscale-bridge", "ips": ["192.168.0.24/24"]}]',
        },
        labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
      },
      spec: {
        serviceAccountName: (import 'sa.jsonnet').metadata.name,
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'tailscale',
            imagePullPolicy: 'IfNotPresent',
            image: 'ghcr.io/tailscale/tailscale:v1.78.3',
            env: [
              {
                name: 'TS_KUBE_SECRET',
                value: 'tailscale',
              },
              {
                name: 'TS_USERSPACE',
                value: 'true',
              },
              {
                name: 'TS_AUTH_KEY',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').metadata.name,
                    key: 'TS_AUTH_KEY',
                    optional: true,
                  },
                },
              },
              {
                name: 'TS_ROUTES',
                value: '192.168.0.2/31,192.168.0.4/30,192.168.0.8/29,192.168.0.16/28,192.168.0.32/27,192.168.0.64/26,192.168.0.128/25,192.168.120.0/24',
              },
              {
                name: 'TS_EXTRA_ARGS',
                value: '--advertise-tags=tag:localserver --snat-subnet-routes=false --accept-routes --reset',
              },
            ],
            securityContext: {
              runAsUser: 1000,
              runAsGroup: 1000,
              readOnlyRootFilesystem: true,
              runAsNonRoot: true,
              seccompProfile: {
                type: 'RuntimeDefault',
              },
            },
            resources: {
              requests: {
                memory: '40Mi',
              },
              limits: {},
            },
            volumeMounts: [
              {
                mountPath: '/tmp',
                name: 'tmp',
              },
            ],
          },
        ],
        priorityClassName: 'high',
        volumes: [
          {
            emptyDir: {},
            name: 'tmp',
          },
        ],
      },
    },
  },
}
