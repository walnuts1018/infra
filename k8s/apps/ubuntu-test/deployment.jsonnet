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
            image: 'ghcr.io/cybozu/ubuntu-debug:26.04@sha256:9815c2f8924b09fa17b1b6f64ccea32ecca6fca4428f5006b29b40ac96a57615',
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
