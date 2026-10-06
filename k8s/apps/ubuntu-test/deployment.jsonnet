local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(app.name),
    },
    template: {
      metadata: {
        labels: labels(app.name),
      },
      spec: {
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'ubuntu-debug',
            image: 'ghcr.io/cybozu/ubuntu-debug:26.04@sha256:e1687b2c79e4d06ac378396e620c44d95e66dbc71c84721f9dcd8181c9088593',
            securityContext:: null,
            command: ['sleep', 'infinity'],
            resources: {
              requests: {
                memory: '5Mi',
              },
              limits: {
                memory: '1Gi',
              },
            },
            volumeMounts: [
              {
                name: 'local-ca-bundle',
                mountPath: '/etc/ssl/certs/trust-bundle.pem',
                subPath: 'trust-bundle.pem',
                readOnly: true,
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'local-ca-bundle',
            configMap: {
              name: (import '../clusterissuer/local-bundle.jsonnet').metadata.name,
            },
          },
        ],
      },
    },
  },
}
