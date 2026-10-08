local app = import 'app.json5';

{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-interceptor-ingress',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: {
        'k8s:io.kubernetes.pod.namespace': app.namespace,
        'k8s:app.kubernetes.io/component': 'interceptor',
        'k8s:app.kubernetes.io/instance': app.name,
        'k8s:app.kubernetes.io/name': 'http-add-on',
        'k8s:app.kubernetes.io/part-of': 'keda-add-ons-http',
      },
    },
    ingress: [
      {
        fromEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'envoy-gateway-system',
            'k8s:app.kubernetes.io/component': 'proxy',
            'k8s:app.kubernetes.io/managed-by': 'envoy-gateway',
            'k8s:app.kubernetes.io/name': 'envoy',
            'k8s:gateway.envoyproxy.io/owning-gateway-name': 'envoy-gateway',
            'k8s:gateway.envoyproxy.io/owning-gateway-namespace': 'envoy-gateway-system',
          },
        }],
        toPorts: [{ ports: [{ port: '8080', protocol: 'TCP' }] }],
      },
      {
        fromEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': app.namespace,
            'k8s:app.kubernetes.io/component': 'scaler',
            'k8s:app.kubernetes.io/instance': app.name,
            'k8s:app.kubernetes.io/name': 'http-add-on',
            'k8s:app.kubernetes.io/part-of': 'keda-add-ons-http',
          },
        }],
        toPorts: [{ ports: [{ port: '9090', protocol: 'TCP' }] }],
      },
      {
        fromEntities: ['host'],
        toPorts: [{ ports: [{ port: '9090', protocol: 'TCP' }] }],
      },
    ],
  },
}
