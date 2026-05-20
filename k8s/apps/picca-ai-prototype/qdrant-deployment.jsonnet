{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'qdrant',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-qdrant'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')('picca-ai-prototype-qdrant'),
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-qdrant'),
      },
      spec: {
        serviceAccountName: (import 'serviceaccount.jsonnet').metadata.name,
        imagePullSecrets: [
          {
            name: 'ghcr-login-secret',
          },
        ],
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'qdrant',
            image: 'qdrant/qdrant:v1.18.0',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                name: 'http',
                containerPort: 6333,
              },
              {
                name: 'grpc',
                containerPort: 6334,
              },
            ],
            resources: {
              requests: {
                cpu: '250m',
                memory: '512Mi',
              },
              limits: {
                cpu: '1',
                memory: '2Gi',
              },
            },
            volumeMounts: [
              {
                name: 'tmp',
                mountPath: '/tmp',
              },
              {
                name: 'qdrant-storage',
                mountPath: '/qdrant/storage',
              },
            ],
          }, {
            securityContext: {
              allowPrivilegeEscalation: false,
            },
          }),
        ],
        volumes: [
          {
            name: 'tmp',
            emptyDir: {},
          },
          {
            name: 'qdrant-storage',
            emptyDir: {},
          },
        ],
      },
    },
  },
}
