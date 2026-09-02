function(app)
  local common = import 'common.libsonnet';
  local imgproxyServiceName = app.name + '-imgproxy';
  local imgproxyDomain = 'imgproxy-' + app.name + '.walnuts.dev';
  {
    apiVersion: 'gateway.networking.k8s.io/v1',
    kind: 'HTTPRoute',
    metadata: {
      name: app.name + '-imgproxy',
      namespace: app.namespace,
    },
    spec: {
      parentRefs: [common.httpsParentRef],
      hostnames: [
        imgproxyDomain,
      ],
      rules: [
        {
          backendRefs: [
            {
              kind: 'Service',
              name: imgproxyServiceName,
              port: 80,
              weight: 1,
            },
          ],
        },
      ],
    },
  }
