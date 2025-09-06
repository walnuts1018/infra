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
        // securityContext: {
        //   fsGroup: 101,
        //   fsGroupChangePolicy: 'OnRootMismatch',
        // },
        containers: [
          {
            name: 'ipxe-manager',
            image: 'docker pull ghcr.io/walnuts1018/ipxe-manager:0.0.10',
            env: [
              {
                name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
                value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4317',
              },
              {
                name: 'CLIENT_ID',
                value: '336650899348783299',
              },
              {
                name: 'CLIENT_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'client-secret',
                  },
                },
              },
              {
                name: 'INTROSPECTION_ENDPOINT',
                value: 'https://auth.walnuts.dev/oauth/v2/introspect',
              },
              {
                name: 'ALLOWED_AUDIENCE',
                value: '336650775264493758',
              },
              {
                name: 'IPXE_SCRIPT_DIR',
                value: '/etc/ipxe',
              },
            ],
            ports: [
              {
                name: 'http',
                containerPort: 8080,
                protocol: 'TCP',
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/livez',
                port: 'http',
              },
            },
            readinessProbe: {
              httpGet: {
                path: '/readyz',
                port: 'http',
              },
            },
            resources: {
              limits: {
                cpu: '100m',
                memory: '300Mi',
              },
              requests: {
                cpu: '1m',
                memory: '10Mi',
              },
            },
            volumeMounts: [
              {
                name: 'ipxe-scripts',
                mountPath: '/etc/ipxe',
                readOnly: true,
              },
              {
                name: 'db',
                mountPath: '/var/lib/ipxe-manager',
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'ipxe-scripts',
            configMap: {
              name: (import 'configmap.jsonnet').metadata.name,
            },
          },
          {
            name: 'db',
            persistentVolumeClaim: {
              claimName: (import 'pvc.jsonnet').metadata.name,
            },
          },
        ],
      },
    },
  },
}
