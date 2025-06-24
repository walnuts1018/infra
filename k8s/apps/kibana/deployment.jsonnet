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
        containers: [
          {
            name: 'kibana',
            securityContext: {
              readOnlyRootFilesystem: true,
              runAsNonRoot: true,
            },
            image: 'docker.elastic.co/kibana/kibana:9.0.3',
            ports: [
              {
                name: 'http',
                containerPort: 5601,
              },
            ],
            env: [
              {
                name: 'ELASTICSEARCH_HOSTS',
                value: 'http://%s.%s.svc.cluster.local:9200' % [(import '../elasticsearch/service.jsonnet').metadata.name, (import '../elasticsearch/app.json5').namespace],
              },
            ],
            resources: {
              limits: {},
              requests: {
                memory: '500Mi',
              },
            },
            volumeMounts: [
              {
                mountPath: '/usr/share/kibana/data',
                name: 'kibana-data',
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'kibana-data',
            emptyDir: {},
          },
        ],
      },
    },
  },
}
