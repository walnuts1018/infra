{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'caption',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-caption'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')('picca-ai-prototype-caption'),
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-caption'),
      },
      spec: {
        serviceAccountName: (import 'serviceaccount.jsonnet').metadata.name,
        imagePullSecrets: [
          { name: 'ghcr-login-secret' },
        ],
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'caption',
            image: 'ghcr.io/walnuts1018/picca-ai-prototype-model:latest',
            imagePullPolicy: 'Always',
            command: [
              'python',
              'scripts/run_caption_service.py',
            ],
            ports: [
              {
                name: 'http',
                containerPort: 8004,
              },
            ],
            env: [
              {
                name: 'PORT',
                value: '8004',
              },
              {
                name: 'MODEL_DEVICE',
                value: 'cpu',
              },
              {
                name: 'FLORENCE2_MODEL_NAME',
                value: '/models/Florence-2-base-ft',
              },
              {
                name: 'TRANSLATE_MODEL_NAME',
                value: '/models/CAT-Translate-0.8b',
              },
            ],
            resources: {
              requests: {
                cpu: '1',
                memory: '4Gi',
              },
              limits: {
                cpu: '4',
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
