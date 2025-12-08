(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'terrakube',
  repoURL: 'https://charts.terrakube.io',
  targetRevision: '4.5.1',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr 'values.yaml'),
    {
      dex: {
        configSecret: {
          name: (import 'external-secret-dex.jsonnet').spec.target.name,
        },
      },
      api: {
        secrets: [
          'terrakube-api-secrets',
          (import 'external-secret-api.jsonnet').spec.target.name,
        ],
        volumes: [
          {
            name: 'minio-sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.min.io',
                    path: 'token',
                    expirationSeconds: 86400,
                  },
                },
              ],
            },
          },
          {
            name: 'aws-config',
            configMap: {
              name: (import 'configmap-aws.jsonnet').metadata.name,
            },
          },
          {
            name: 'aws-cli',
            image: {
              reference: 'public.ecr.aws/aws-cli/aws-cli:2.32.11',
            },
          },
        ],
      },
      executor: {
        secrets: [
          'terrakube-executor-secrets',
          (import 'external-secret-executor.jsonnet').spec.target.name,
        ],
        volumes: [
          {
            name: 'minio-sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.min.io',
                    path: 'token',
                    expirationSeconds: 86400,
                  },
                },
              ],
            },
          },
          {
            name: 'aws-config',
            configMap: {
              name: (import 'configmap-aws.jsonnet').metadata.name,
            },
          },
          {
            name: 'aws-cli',
            image: {
              reference: 'public.ecr.aws/aws-cli/aws-cli:2.32.11',
            },
          },
        ],
      },
      registry: {
        secrets: [
          'terrakube-registry-secrets',
          (import 'external-secret-registry.jsonnet').spec.target.name,
        ],
        volumes: [
          {
            name: 'minio-sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.min.io',
                    path: 'token',
                    expirationSeconds: 86400,
                  },
                },
              ],
            },
          },
          {
            name: 'aws-config',
            configMap: {
              name: (import 'configmap-aws.jsonnet').metadata.name,
            },
          },
          {
            name: 'aws-cli',
            image: {
              reference: 'public.ecr.aws/aws-cli/aws-cli:2.32.11',
            },
          },
        ],
      },
    }
  ),
}
