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
            name: 'esp32-thermohygrometer-exporter',
            image: 'ghcr.io/walnuts1018/esp32-thermohygrometer-exporter:v0.0.21',
            imagePullPolicy: 'IfNotPresent',
            resources: {
              requests: {
                cpu: '2m',
                memory: '10Mi',
              },
              limits: {
                cpu: '100m',
                memory: '128Mi',
              },
            },
            livenessProbe: {
              httpGet: {
                path: '/livez',
                port: 8080,
              },
              initialDelaySeconds: 0,
              periodSeconds: 10,
              timeoutSeconds: 1,
              failureThreshold: 3,
            },
            readinessProbe: {
              httpGet: {
                path: '/readyz',
                port: 8080,
              },
              initialDelaySeconds: 0,
              periodSeconds: 5,
              timeoutSeconds: 1,
              failureThreshold: 3,
            },
            startupProbe: {
              httpGet: {
                path: '/livez',
                port: 8080,
              },
              periodSeconds: 1,
              timeoutSeconds: 1,
              failureThreshold: 30,
            },
            env: [
              {
                name: 'FETCH_INTERVAL',
                value: '30s',
              },
              {
                name: 'DEVICE_URL',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'device_url',
                  },
                },
              },
              {
                name: 'OIDC_PRIVATE_KEY_JSON',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'private_key_json',
                  },
                },
              },
              {
                local projectID = '375241036420612774',
                name: 'OIDC_SCOPES',
                value: 'openid urn:zitadel:iam:org:project:id:' + projectID + ':aud urn:zitadel:iam:org:project:role:thermohygrometer.read',
              },
              {
                name: 'OIDC_ISSUER',
                value: 'https://auth.walnuts.dev',
              },
              {
                name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
                value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4317',
              },
              {
                name: 'OTEL_EXPORTER_OTLP_INSECURE',
                value: 'true',
              },
              {
                name: 'LOG_LEVEL',
                value: 'info',
              },
              {
                name: 'LOG_TYPE',
                value: 'json',
              },
            ],
          },
        ],
      },
    },
  },
}
