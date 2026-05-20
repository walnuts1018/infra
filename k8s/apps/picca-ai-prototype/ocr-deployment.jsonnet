{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'ocr',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-ocr'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')('picca-ai-prototype-ocr'),
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-ocr'),
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
            name: 'ocr',
            image: 'ghcr.io/walnuts1018/picca-ai-prototype-model:latest',
            imagePullPolicy: 'Always',
            command: [
              'python',
              'scripts/run_ocr_service.py',
            ],
            ports: [
              {
                name: 'http',
                containerPort: 8003,
              },
            ],
            env: [
              {
                name: 'PORT',
                value: '8003',
              },
              {
                name: 'MODEL_DEVICE',
                value: 'cpu',
              },
              {
                name: 'PADDLEX_HOME',
                value: '/models/paddlex',
              },
            ],
            resources: {
              requests: {
                cpu: '300m',
                memory: '5.8Gi',
              },
              limits: {
                cpu: '2',
                memory: '16Gi',
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
