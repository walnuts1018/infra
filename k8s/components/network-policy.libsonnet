{
  envoyGatewayProxy: {
    namespaceSelector: {
      matchLabels: {
        'kubernetes.io/metadata.name': 'envoy-gateway-system',
      },
    },
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/component': 'proxy',
        'app.kubernetes.io/managed-by': 'envoy-gateway',
        'app.kubernetes.io/name': 'envoy',
      },
    },
  },
  otelDefaultCollector: {
    namespaceSelector: {
      matchLabels: {
        'kubernetes.io/metadata.name': 'opentelemetry-collector',
      },
    },
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/component': 'opentelemetry-collector',
        'app.kubernetes.io/instance': 'opentelemetry-collector.default',
        'app.kubernetes.io/name': 'default-collector',
      },
    },
  },
  otelPrometheusCollector: {
    namespaceSelector: {
      matchLabels: {
        'kubernetes.io/metadata.name': 'opentelemetry-collector',
      },
    },
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/component': 'opentelemetry-collector',
        'app.kubernetes.io/instance': 'opentelemetry-collector.prometheus',
      },
    },
  },
  kedaHttpInterceptor: {
    namespaceSelector: {
      matchLabels: {
        'kubernetes.io/metadata.name': 'keda',
      },
    },
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/component': 'interceptor',
        'app.kubernetes.io/instance': 'keda-http-addon',
        'app.kubernetes.io/name': 'http-add-on',
        'app.kubernetes.io/part-of': 'keda-add-ons-http',
      },
    },
  },
}
