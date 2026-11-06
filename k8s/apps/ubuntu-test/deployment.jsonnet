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
            image: 'ghcr.io/cybozu/ubuntu-debug:26.04@sha256:81b2e4a7bc9c6a59630288116d5fee2cd29f53a1c8f2f96e7dc1bc438ab03ff4',
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
