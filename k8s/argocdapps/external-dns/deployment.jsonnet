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
        serviceAccountName: (import './service-account.jsonnet').metadata.name,
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'external-dns',
            image: 'ghcr.io/walnuts1018/external-dns:670a2816bbb5c344117eab45003d7a6ff2c86349-10',
            args: [
              '--source=ingress',
              '--domain-filter=walnuts.dev',
              '--provider=cloudflare-tunnel',
              '--annotation-filter=walnuts.dev/externaldns.skip notin (true)',
            ],
            env: [
              {
                name: 'CF_API_TOKEN',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'cf-api-token',
                  },
                },
              },
              {
                name: 'CF_ACCOUNT_ID',
                value: '38b5eab012d216dfcc52dcd69e7764b5',
              },
              {
                name: 'CF_TUNNEL_ID',
                value: '603f4f99-268a-4d2a-8c2a-66d29ef1f528',
              },
            ],
            resources: {
              requests: {
                memory: '32Mi',
              },
              limits: {},
            },
          },
        ],
        nodeSelector: {
          'kubernetes.io/arch': 'amd64',
        },
      },
    },
  },
}
