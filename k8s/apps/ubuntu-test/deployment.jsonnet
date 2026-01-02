{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
      },
      spec: {
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'ubuntu-debug',
            image: 'ghcr.io/cybozu/ubuntu-debug:24.04',
            securityContext:: null,
            command: ['sleep', 'infinity'],
            resources: {
              limits: {
                memory: '100Mi',
              },
              requests: {
                memory: '5Mi',
              },
            },
            volumeMounts: [
              {
                name: 'local-ca-bundle',
                mountPath: '/etc/ssl/certs/trust-bundle.pem',
                subPath: 'trust-bundle.pem',
                readOnly: true,
              },
              {
                name: 'localpath',
                mountPath: '/mnt/localpath',
              },
              {
                name: 'longhorn',
                mountPath: '/mnt/longhorn',
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
          {
            name: 'localpath',
            persistentVolumeClaim: {
              claimName: (import 'pvc-localpath.jsonnet').metadata.name,
            },
          },
          {
            name: 'longhorn',
            persistentVolumeClaim: {
              claimName: (import 'pvc-longhorn.jsonnet').metadata.name,
            },
          },
        ],
      },
    },
  },
}
