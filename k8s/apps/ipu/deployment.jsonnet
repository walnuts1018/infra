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
        serviceAccountName: (import 'sa.jsonnet').metadata.name,
        securityContext: {
          fsGroup: 101,
          fsGroupChangePolicy: 'OnRootMismatch',
        },
        containers: [
          {
            name: 'sigv4-proxy',
            image: 'public.ecr.aws/aws-observability/aws-sigv4-proxy:1.10',
            env: [
              {
                name: 'AWS_CA_BUNDLE',
                value: '/etc/ssl/certs/trust-bundle.pem',
              },
              {
                name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
                value: '/var/run/secrets/sts.min.io/serviceaccount/token',
              },
              {
                name: 'AWS_ENDPOINT_URL_STS',
                value: 'https://sts.minio-operator.svc.cluster.local:4223/sts/test',
              },
              {
                name: 'AWS_ROLE_ARN',
                value: 'arn:aws:iam::dummy:role/test',
              },
            ],
            args: [
              '--name',
              's3',
              '--region',
              'ap-northeast-1',
              '--host',
              'test-hl.minio-test.svc.cluster.local',
            ],
            ports: [
              {
                name: 'http',
                containerPort: 8080,
                protocol: 'TCP',
              },
            ],
            // livenessProbe: {
            //   httpGet: {
            //     path: '/health',
            //     port: 'http',
            //   },
            // },
            // readinessProbe: {
            //   httpGet: {
            //     path: '/health',
            //     port: 'http',
            //   },
            // },
            resources: {
              limits: {
                memory: '100Mi',
              },
              requests: {
                memory: '10Mi',
              },
            },
            volumeMounts: [
              {
                name: 'minio-sts-token',
                mountPath: '/var/run/secrets/sts.min.io/serviceaccount',
                readOnly: true,
              },
              {
                name: 'local-ca-bundle',
                mountPath: '/etc/ssl/certs/trust-bundle.pem',
                subPath: 'trust-bundle.pem',
                readOnly: true,
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'minio-sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.min.io',
                    expirationSeconds: 86400,
                    path: 'token',
                  },
                },
              ],
            },
          },
          {
            name: 'local-ca-bundle',
            configMap: {
              name: (import '../clusterissuer/local-bundle.jsonnet').metadata.name,
            },
          },
        ],
      },
    },
  },
}
