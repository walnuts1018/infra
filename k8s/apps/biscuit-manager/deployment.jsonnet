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
        labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
      },
      spec: {
        serviceAccountName: (import 'sa.jsonnet').metadata.name,
        containers: [
          {
            name: 'ubuntu-debug',
            image: 'ghcr.io/cybozu/ubuntu-debug:24.04',
            securityContext:: null,
            command: ['sleep', 'infinity'],
            volumeMounts: [
              {
                name: 'shutdown-manager-token',
                mountPath: '/var/run/secrets/shutdown-manager.local.walnuts.dev/serviceaccount',
                readOnly: true,
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'shutdown-manager-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'shutdown-manager.local.walnuts.dev',
                    expirationSeconds: 86400,
                    path: 'token',
                  },
                },
              ],
            },
          },
        ],
      },
    },
  },
}
