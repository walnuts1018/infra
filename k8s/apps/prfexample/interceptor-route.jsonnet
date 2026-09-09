local app = import 'app.json5';

{
  apiVersion: 'http.keda.sh/v1beta1',
  kind: 'InterceptorRoute',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    target: {
      service: app.name,
      port: 8080,
    },
    rules: [
      {
        hosts: ['prfexample.walnuts.dev'],
      },
    ],
    scalingMetric: {
      concurrency: {
        targetValue: 10,
      },
    },
  },
}
