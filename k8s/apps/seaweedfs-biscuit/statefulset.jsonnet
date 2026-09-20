local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local componentLabels = labels(app.name) + {
  'app.kubernetes.io/component': 'mini',
};
{
  apiVersion: 'apps/v1',
  kind: 'StatefulSet',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: componentLabels,
    annotations: {
      'reloader.stakater.com/auto': 'true',
    },
  },
  spec: {
    replicas: 1,
    serviceName: app.name,
    podManagementPolicy: 'OrderedReady',
    updateStrategy: {
      type: 'RollingUpdate',
    },
    selector: {
      matchLabels: componentLabels,
    },
    template: {
      metadata: {
        labels: componentLabels,
      },
      spec: {
        automountServiceAccountToken: false,
        securityContext: {
          seccompProfile: {
            type: 'RuntimeDefault',
          },
        },
        terminationGracePeriodSeconds: 60,
        containers: [
          {
            name: 'seaweedfs',
            securityContext: {
              allowPrivilegeEscalation: false,
              capabilities: {
                drop: ['ALL'],
              },
            },
            image: 'chrislusf/seaweedfs@sha256:aa0d394e64735d240d57673b6745ee344360a9fab9ca0b26e4ed3707d135f570',  // 4.45_large_disk_full
            imagePullPolicy: 'IfNotPresent',
            args: [
              'mini',
              '-dir=/data',
              '-master.dir=/meta/master',
              '-master.defaultReplication=000',
              '-master.volumeSizeLimitMB=30000',
              '-volume.index=memory',
              '-s3.config=/etc/seaweedfs/s3/seaweedfs_s3_config.json',
              '-s3.iam.readOnly=true',
              '-s3.port=8333',
              '-s3.port.iceberg=0',
              '-s3.port.lance=0',
              '-webdav=false',
              '-admin.ui=false',
            ],
            ports: [
              {
                name: 's3',
                containerPort: 8333,
                protocol: 'TCP',
              },
            ],
            startupProbe: {
              httpGet: {
                path: '/readyz',
                port: 's3',
                scheme: 'HTTP',
              },
              periodSeconds: 5,
              timeoutSeconds: 3,
              failureThreshold: 120,
            },
            readinessProbe: {
              httpGet: {
                path: '/readyz',
                port: 's3',
                scheme: 'HTTP',
              },
              periodSeconds: 10,
              timeoutSeconds: 3,
              failureThreshold: 6,
            },
            livenessProbe: {
              httpGet: {
                path: '/healthz',
                port: 's3',
                scheme: 'HTTP',
              },
              periodSeconds: 20,
              timeoutSeconds: 5,
              failureThreshold: 6,
            },
            resources: {
              requests: {
                cpu: '100m',
                memory: '512Mi',
              },
              limits: {
                cpu: '2',
                memory: '4Gi',
              },
            },
            volumeMounts: [
              {
                name: 'meta',
                mountPath: '/meta',
              },
              {
                name: 'data',
                mountPath: '/data',
              },
              {
                name: 'filer-config',
                mountPath: '/etc/seaweedfs/filer.toml',
                subPath: 'filer.toml',
                readOnly: true,
              },
              {
                name: 's3-config',
                mountPath: '/etc/seaweedfs/s3',
                readOnly: true,
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'meta',
            persistentVolumeClaim: {
              claimName: 'seaweedfs-meta',
            },
          },
          {
            name: 'data',
            persistentVolumeClaim: {
              claimName: 'seaweedfs-volume',
            },
          },
          {
            name: 'filer-config',
            configMap: {
              name: app.name + '-filer-config',
            },
          },
          {
            name: 's3-config',
            secret: {
              secretName: app.name + '-s3-config',
            },
          },
        ],
      },
    },
  },
}
