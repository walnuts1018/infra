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
            name: 'nginx',
            image: 'ghcr.io/nginxinc/nginx-s3-gateway/nginx-oss-s3-gateway:latest-20250331',  // TODO: renovate
            env: [
              {
                name: 'S3_BUCKET_NAME',
                value: 'static',
              },
              {
                name: 'S3_SERVER',
                value: 'test-hl.minio-test.svc.cluster.local',
              },
              {
                name: 'S3_SERVER_PROTO',
                value: 'http',
              },
              {
                name: 'S3_SERVER_PORT',
                value: '9000',
              },
              {
                name: 'S3_STYLE',
                value: 'path',
              },
              {
                name: 'S3_REGION',
                value: 'ap-northeast-1',
              },
              {
                name: 'AWS_REGION',
                value: 'ap-northeast-1',
              },
              {
                name: 'AWS_SIGS_VERSION',
                value: '4',
              },
              {
                name: 'ALLOW_DIRECTORY_LIST',
                value: 'false',
              },
              {
                name: 'PROVIDE_INDEX_PAGE',
                value: 'false',
              },
              {
                name: 'STS_ENDPOINT',
                value: 'https://sts.minio-operator.svc.cluster.local',
              },
            ],
            ports: [
              {
                name: 'http',
                containerPort: 80,
                protocol: 'TCP',
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/health',
                port: 'http',
              },
            },
            readinessProbe: {
              httpGet: {
                path: '/health',
                port: 'http',
              },
            },
            resources: {
              limits: {
                memory: '100Mi',
              },
              requests: {
                memory: '10Mi',
              },
            },
          },
        ],
      },
    },
  },
}
