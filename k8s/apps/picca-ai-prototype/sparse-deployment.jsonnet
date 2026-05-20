{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'sparse',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-sparse'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')('picca-ai-prototype-sparse'),
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-sparse'),
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
            name: 'sparse',
            image: 'ghcr.io/walnuts1018/picca-ai-prototype-model:latest',
            imagePullPolicy: 'Always',
            command: [
              'python',
              'scripts/run_sparse_service.py',
            ],
            ports: [
              {
                name: 'http',
                containerPort: 8002,
              },
            ],
            env: [
              {
                name: 'PORT',
                value: '8002',
              },
              {
                name: 'MODEL_DEVICE',
                value: 'cpu',
              },
              {
                name: 'SPARSE_MODEL_NAME',
                value: '/models/light-splade-japanese-28M',
              },
            ],
            resources: {
              requests: {
                cpu: '500m',
                memory: '2Gi',
              },
              limits: {
                cpu: '2',
                memory: '6Gi',
              },
            },
            volumeMounts: [
              {
                name: 'tmp',
                mountPath: '/tmp',
              },
              {
                name: 'models',
                mountPath: '/models',
                readOnly: true,
              },
            ],
          }, {
            securityContext: {
              allowPrivilegeEscalation: false,
              readOnlyRootFilesystem: false,
            },
          }),
        ],
        volumes: [
          {
            name: 'tmp',
            emptyDir: {},
          },
          {
            name: 'models',
            image: {
              reference: 'ghcr.io/walnuts1018/picca-ai-prototype-models:dev',
              pullPolicy: 'Always',
            },
          },
        ],
      },
    },
  },
}
