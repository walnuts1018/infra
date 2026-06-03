local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'apps/v1',
  kind: 'DaemonSet',
  metadata: {
    name: 'kubernetes-control-plane-metrics-proxy',
    namespace: 'kube-system',
    labels: labels(app.name) + {
      app: 'kubernetes-control-plane-metrics-proxy',
    },
  },
  spec: {
    selector: {
      matchLabels: {
        app: 'kubernetes-control-plane-metrics-proxy',
      },
    },
    template: {
      metadata: {
        labels: labels(app.name) + {
          app: 'kubernetes-control-plane-metrics-proxy',
        },
      },
      spec: {
        hostNetwork: true,
        dnsPolicy: 'ClusterFirstWithHostNet',
        nodeSelector: {
          'node-role.kubernetes.io/control-plane': '',
        },
        tolerations: [
          {
            key: 'node-role.kubernetes.io/control-plane',
            operator: 'Exists',
            effect: 'NoSchedule',
          },
        ],
        containers: [
          {
            name: 'controller-manager',
            image: 'docker.io/alpine/socat:1.8.0.3',
            args: [
              '-d',
              '-d',
              'TCP-LISTEN:11057,fork,reuseaddr,bind=0.0.0.0',
              'TCP:127.0.0.1:10257',
            ],
            ports: [
              {
                name: 'controller',
                containerPort: 11057,
                hostPort: 11057,
              },
            ],
            resources: {
              requests: {
                cpu: '5m',
                memory: '8Mi',
              },
              limits: {
                cpu: '50m',
                memory: '32Mi',
              },
            },
          },
          {
            name: 'scheduler',
            image: 'docker.io/alpine/socat:1.8.0.3',
            args: [
              '-d',
              '-d',
              'TCP-LISTEN:11059,fork,reuseaddr,bind=0.0.0.0',
              'TCP:127.0.0.1:10259',
            ],
            ports: [
              {
                name: 'scheduler',
                containerPort: 11059,
                hostPort: 11059,
              },
            ],
            resources: {
              requests: {
                cpu: '5m',
                memory: '8Mi',
              },
              limits: {
                cpu: '50m',
                memory: '32Mi',
              },
            },
          },
          {
            name: 'etcd',
            image: 'docker.io/alpine/socat:1.8.0.3',
            args: [
              '-d',
              '-d',
              'TCP-LISTEN:12381,fork,reuseaddr,bind=0.0.0.0',
              'TCP:127.0.0.1:2381',
            ],
            ports: [
              {
                name: 'etcd',
                containerPort: 12381,
                hostPort: 12381,
              },
            ],
            resources: {
              requests: {
                cpu: '5m',
                memory: '8Mi',
              },
              limits: {
                cpu: '50m',
                memory: '32Mi',
              },
            },
          },
        ],
      },
    },
  },
}
