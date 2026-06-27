local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'apps/v1',
  kind: 'DaemonSet',
  metadata: {
    name: 'kubelet-metrics-proxy',
    namespace: 'kube-system',
    labels: labels(app.name) + {
      app: 'kubelet-metrics-proxy',
    },
  },
  spec: {
    selector: {
      matchLabels: {
        app: 'kubelet-metrics-proxy',
      },
    },
    template: {
      metadata: {
        labels: labels(app.name) + {
          app: 'kubelet-metrics-proxy',
        },
      },
      spec: {
        hostNetwork: true,
        dnsPolicy: 'ClusterFirstWithHostNet',
        tolerations: [
          {
            operator: 'Exists',
          },
        ],
        containers: [
          {
            name: 'kubelet',
            image: 'docker.io/alpine/socat:1.8.1.3',
            args: [
              '-d',
              '-d',
              'TCP-LISTEN:11050,fork,reuseaddr,bind=0.0.0.0',
              'TCP:127.0.0.1:10250',
            ],
            ports: [
              {
                name: 'https-metrics',
                containerPort: 11050,
                hostPort: 11050,
              },
            ],
            resources: {
              requests: {
                cpu: '5m',
                memory: '48Mi',
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
