{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import '../app.json5').backend.name,
    namespace: (import '../app.json5').namespace,
    labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').backend.name },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').backend.name },
    },
    template: {
      metadata: {
        labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').backend.name },
      },
      spec: {
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'ac-hacking-2024-back',
            image: 'ghcr.io/walnuts1018/2024-ac-hacking:1c4c5593eb14f8656449d2176c177ca20679ef56-11',
            securityContext: {
              readOnlyRootFilesystem: true,
            },
            ports: [
              {
                containerPort: 8080,
              },
            ],
            resources: {
              requests: {
                cpu: '1m',
                memory: '5Mi',
              },
              limits: {
                memory: '64Mi',
              },
            },
            env: [
              {
                name: 'PSQL_HOST',
                value: 'postgresql-default-rw.databases.svc.cluster.local',
              },
              {
                name: 'PSQL_PORT',
                value: '5432',
              },
              {
                name: 'PSQL_DATABASE',
                value: 'ac_hacking',
              },
              {
                name: 'PSQL_USER',
                value: 'ac_hacking',
              },
              {
                name: 'PSQL_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: (import './external-secret.jsonnet').spec.target.name,
                    key: 'postgres_password',
                  },
                },
              },
              {
                name: 'PSQL_SSLMODE',
                value: 'disable',
              },
              {
                name: 'PROXY_PASSWORD',
                value: 'sukina-souzai-happyo-doragon',
              },
              {
                name: 'FRONT_URL',
                value: 'http://ac-hacking-2024-front.ac-hacking-2024.svc.cluster.local:3000',
              },
            ],
          },
        ],
        nodeSelector: {
          'kubernetes.io/arch': 'amd64',
        },
      },
    },
  },
}
