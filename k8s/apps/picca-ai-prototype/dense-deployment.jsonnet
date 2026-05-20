{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'dense',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-dense'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')('picca-ai-prototype-dense'),
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-dense'),
      },
      spec: {
        serviceAccountName: (import 'serviceaccount.jsonnet').metadata.name,
        imagePullSecrets: [
          { name: 'ghcr-login-secret' },
        ],
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'dense',
            image: 'ghcr.io/walnuts1018/picca-ai-prototype-model-cuda:latest',
            imagePullPolicy: 'Always',
            command: [
              'python',
              'scripts/run_dense_service.py',
            ],
            ports: [
              {
                name: 'http',
                containerPort: 8001,
              },
            ],
            env: [
              {
                name: 'PORT',
                value: '8001',
              },
              {
                name: 'MODEL_DEVICE',
                value: 'cuda',
              },
              {
                name: 'DENSE_MODEL_NAME',
                value: '/models/waon-siglip2-base-patch16-256',
              },
            ],
            resources: {
              requests: {
                cpu: '1',
                memory: '4Gi',
                'nvidia.com/gpu': '1',
              },
              limits: {
                cpu: '4',
                memory: '12Gi',
                'nvidia.com/gpu': '1',
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
