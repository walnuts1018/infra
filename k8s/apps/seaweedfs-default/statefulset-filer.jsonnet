{
  apiVersion: 'apps/v1',
  kind: 'StatefulSet',
  metadata: {
    name: 'seaweedfs-default-filer-manual',
    namespace: 'seaweedfs',
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: {
        'app.kubernetes.io/component': 'filer',
        'app.kubernetes.io/instance': 'seaweedfs-default',
        'app.kubernetes.io/managed-by': 'seaweedfs-operator',
        'app.kubernetes.io/name': 'seaweedfs',
      },
    },
    serviceName: 'seaweedfs-default-filer-peer',
    template: {
      metadata: {
        labels: {
          'app.kubernetes.io/component': 'filer',
          'app.kubernetes.io/instance': 'seaweedfs-default',
          'app.kubernetes.io/managed-by': 'seaweedfs-operator',
          'app.kubernetes.io/name': 'seaweedfs',
        },
      },
      spec: {
        containers: [
          {
            command: [
              '/bin/sh',
              '-ec',
              'weed -logtostderr=true filer -port=8888 -ip=$(POD_NAME).seaweedfs-default-filer-peer.seaweedfs -master=seaweedfs-default-master-0.seaweedfs-default-master-peer.seaweedfs:9333,seaweedfs-default-master-1.seaweedfs-default-master-peer.seaweedfs:9333,seaweedfs-default-master-2.seaweedfs-default-master-peer.seaweedfs:9333 -s3',
            ],
            env: [
              {
                name: 'POD_IP',
                valueFrom: {
                  fieldRef: {
                    apiVersion: 'v1',
                    fieldPath: 'status.podIP',
                  },
                },
              },
              {
                name: 'POD_NAME',
                valueFrom: {
                  fieldRef: {
                    apiVersion: 'v1',
                    fieldPath: 'metadata.name',
                  },
                },
              },
              {
                name: 'NAMESPACE',
                valueFrom: {
                  fieldRef: {
                    apiVersion: 'v1',
                    fieldPath: 'metadata.namespace',
                  },
                },
              },
            ],
            image: 'ghcr.io/walnuts1018/seaweedfs:dev',
            imagePullPolicy: 'IfNotPresent',
            livenessProbe: {
              failureThreshold: 6,
              httpGet: {
                path: '/',
                port: 8888,
                scheme: 'HTTP',
              },
              initialDelaySeconds: 20,
              periodSeconds: 30,
              successThreshold: 1,
              timeoutSeconds: 3,
            },
            name: 'filer',
            ports: [
              {
                containerPort: 8888,
                name: 'filer-http',
                protocol: 'TCP',
              },
              {
                containerPort: 18888,
                name: 'filer-grpc',
                protocol: 'TCP',
              },
              {
                containerPort: 8333,
                name: 'filer-s3',
                protocol: 'TCP',
              },
            ],
            readinessProbe: {
              failureThreshold: 100,
              httpGet: {
                path: '/',
                port: 8888,
                scheme: 'HTTP',
              },
              initialDelaySeconds: 10,
              periodSeconds: 15,
              successThreshold: 1,
              timeoutSeconds: 3,
            },
            resources: {
              limits: {
                cpu: '200m',
                memory: '256Mi',
              },
              requests: {
                cpu: '100m',
                memory: '128Mi',
              },
            },
            volumeMounts: [
              {
                mountPath: '/etc/seaweedfs',
                name: 'filer-config',
                readOnly: true,
              },
              {
                mountPath: '/etc/seaweedfs/scylladb-ca',
                name: 'scylla-db-ca-cert',
                readOnly: true,
              },
              {
                mountPath: '/etc/seaweedfs/scylladb-client',
                name: 'scylla-db-client-cert',
                readOnly: true,
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'filer-config',
            secret: {
              secretName: (import 'external-secret-config.jsonnet').spec.target.name,
            },
          },
          {
            name: 'scylla-db-ca-cert',
            configMap: {
              name: (import 'configmap-scylladb-ca.jsonnet').metadata.name,
              items: [
                {
                  key: 'ca.crt',
                  path: 'ca.crt',
                },
              ],
            },
          },
          {
            name: 'scylla-db-client-cert',
            secret: {
              secretName: 'scylla-cluster-local-client-ca',  // database namespaceから手動コピーしてるけどいい方法を考えないといけない
              items: [
                {
                  key: 'tls.crt',
                  path: 'tls.crt',
                },
                {
                  key: 'tls.key',
                  path: 'tls.key',
                },
              ],
            },
          },
        ],
      },
    },
  },
}
