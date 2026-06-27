local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';

{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  spec: {
    parentRefs: [
      {
        name: gateway.metadata.name,
        namespace: gateway.metadata.namespace,
      },
    ],
    hostnames: [
      app.name + '-gateway.' + app.namespace + '.svc.cluster.local',
    ],
    rules: [
      {
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/diode/auth',
            },
          },
        ],
        filters: [
          {
            type: 'URLRewrite',
            urlRewrite: {
              path: {
                type: 'ReplacePrefixMatch',
                replacePrefixMatch: '/',
              },
            },
          },
        ],
        backendRefs: [
          {
            kind: 'Service',
            name: 'diode-auth',
            port: 8080,
            weight: 1,
          },
        ],
      },
      {
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/diode/diode.v1.IngesterService',
            },
          },
        ],
        filters: [
          {
            type: 'URLRewrite',
            urlRewrite: {
              path: {
                type: 'ReplacePrefixMatch',
                replacePrefixMatch: '/diode.v1.IngesterService',
              },
            },
          },
        ],
        backendRefs: [
          {
            kind: 'Service',
            name: app.name + '-ingester-h2c',
            port: 8081,
            weight: 1,
          },
        ],
      },
      {
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/diode/diode.v1.ReconcilerService',
            },
          },
        ],
        filters: [
          {
            type: 'URLRewrite',
            urlRewrite: {
              path: {
                type: 'ReplacePrefixMatch',
                replacePrefixMatch: '/diode.v1.ReconcilerService',
              },
            },
          },
        ],
        backendRefs: [
          {
            kind: 'Service',
            name: app.name + '-reconciler-h2c',
            port: 8081,
            weight: 1,
          },
        ],
      },
    ],
  },
}
