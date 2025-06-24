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
        securityContext: {
          fsGroup: 1000,
          fsGroupChangePolicy: 'OnRootMismatch',
        },
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'elasticsearch',
            securityContext: {
              seccompProfile: {
                type: 'RuntimeDefault',
              },
            },
            image: 'docker.elastic.co/elasticsearch/elasticsearch:9.0.3',
            ports: [
              {
                containerPort: 9200,
              },
            ],
            resources: {
              requests: {
                cpu: '10m',
                memory: '3000Mi',
              },
              limits: {
                cpu: '1',
                memory: '6000Mi',
              },
            },
            env: [
              {
                name: 'discovery.type',
                value: 'single-node',
              },
              {
                name: 'cluster.name',
                value: 'kurumi',
              },
              {
                name: 'xpack.security.enabled',
                value: 'false',
              },
            ],
            volumeMounts: [
              {
                name: 'config',
                mountPath: '/usr/share/elasticsearch/config/elasticsearch-plugins.yml',
                subPath: 'elasticsearch-plugins.yml',
                readOnly: true,
              },
              {
                name: 'data',
                mountPath: '/usr/share/elasticsearch/data',
              },
              {
                name: 'tmp',
                mountPath: '/tmp',
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'config',
            configMap: {
              name: (import 'configmap.jsonnet').metadata.name,
            },
          },
          {
            name: 'data',
            persistentVolumeClaim: {
              claimName: (import 'pvc.jsonnet').metadata.name,
            },
          },
          {
            name: 'tmp',
            emptyDir: {},
          },
        ],
      },
    },
  },
}
