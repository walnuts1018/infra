local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

local name = app.name + '-volume-hdd';
local masterPeers = std.join(',', [
  app.name + '-master-' + std.toString(i) + '.' + app.name + '-master-peer.' + app.namespace + ':9333'
  for i in std.range(0, 2)
]);
local componentLabels = labels(app.name) + {
  'app.kubernetes.io/component': 'volume',
  'app.kubernetes.io/name': name,
};

[
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: name + '-peer',
      namespace: app.namespace,
      labels: componentLabels,
    },
    spec: {
      clusterIP: 'None',
      publishNotReadyAddresses: true,
      selector: componentLabels,
      ports: [
        {
          name: 'volume-http',
          port: 8444,
          targetPort: 'volume-http',
        },
        {
          name: 'volume-grpc',
          port: 18444,
          targetPort: 'volume-grpc',
        },
        {
          name: 'metrics',
          port: 9327,
          targetPort: 'metrics',
        },
      ],
    },
  },
  {
    apiVersion: 'apps/v1',
    kind: 'StatefulSet',
    metadata: {
      name: name,
      namespace: app.namespace,
      labels: componentLabels,
    },
    spec: {
      replicas: 1,
      serviceName: name + '-peer',
      selector: {
        matchLabels: componentLabels,
      },
      template: {
        metadata: {
          labels: componentLabels,
        },
        spec: {
          nodeSelector: {
            'kubernetes.io/hostname': 'rusk',
          },
          containers: [
            {
              name: 'volume',
              image: (import 'seaweed.jsonnet').spec.image,
              imagePullPolicy: 'IfNotPresent',
              command: [
                '/bin/sh',
                '-ec',
                'weed -logtostderr=true volume -port=8444 -max=1000 -ip=$(POD_NAME).' + name + '-peer.' + app.namespace + ' -ip.bind=0.0.0.0 -mserver=' + masterPeers + ' -dir=/data -disk=hdd -metricsPort=9327 -minFreeSpacePercent=10',
              ],
              env: [
                {
                  name: 'POD_NAME',
                  valueFrom: {
                    fieldRef: {
                      fieldPath: 'metadata.name',
                    },
                  },
                },
              ],
              ports: [
                { name: 'volume-http', containerPort: 8444 },
                { name: 'volume-grpc', containerPort: 18444 },
                { name: 'metrics', containerPort: 9327 },
              ],
              readinessProbe: {
                httpGet: {
                  path: '/status',
                  port: 'volume-http',
                },
                initialDelaySeconds: 10,
                periodSeconds: 10,
                failureThreshold: 6,
              },
              livenessProbe: {
                httpGet: {
                  path: '/status',
                  port: 'volume-http',
                },
                initialDelaySeconds: 20,
                periodSeconds: 30,
                failureThreshold: 6,
              },
              resources: {
                requests: {
                  cpu: '10m',
                  memory: '10Mi',
                },
                limits: {
                  memory: '2Gi',
                },
              },
              volumeMounts: [
                {
                  name: 'data',
                  mountPath: '/data',
                },
              ],
            },
          ],
        },
      },
      volumeClaimTemplates: [
        {
          metadata: {
            name: 'data',
          },
          spec: {
            accessModes: ['ReadWriteOnce'],
            storageClassName: 'topolvm-hdd',
            resources: {
              requests: {
                storage: '256Gi',
              },
            },
          },
        },
      ],
    },
  },
]
