local ipv4NonPublic = [
  '0.0.0.0/8',
  '10.0.0.0/8',
  '100.64.0.0/10',
  '127.0.0.0/8',
  '169.254.0.0/16',
  '172.16.0.0/12',
  '192.0.0.0/24',
  '192.0.2.0/24',
  '192.168.0.0/16',
  '198.18.0.0/15',
  '198.51.100.0/24',
  '203.0.113.0/24',
  '224.0.0.0/4',
  '240.0.0.0/4',
];
local ipv6NonPublic = [
  '::/128',
  '::1/128',
  '64:ff9b::/96',
  '100::/64',
  '2001:db8::/32',
  'fc00::/7',
  'fe80::/10',
  'ff00::/8',
];
{
  kubeDns: {
    namespaceSelector: {
      matchLabels: {
        'kubernetes.io/metadata.name': 'kube-system',
      },
    },
    podSelector: {
      matchLabels: {
        'k8s-app': 'kube-dns',
      },
    },
  },
  publicInternet: [
    {
      ipBlock: {
        cidr: '0.0.0.0/0',
        except: ipv4NonPublic,
      },
    },
    {
      ipBlock: {
        cidr: '::/0',
        except: ipv6NonPublic,
      },
    },
  ],
  publicInternetCIDRSet: [
    {
      cidr: '0.0.0.0/0',
      except: ipv4NonPublic,
    },
    {
      cidr: '::/0',
      except: ipv6NonPublic,
    },
  ],
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
  otelCollectors: {
    namespaceSelector: {
      matchLabels: {
        'kubernetes.io/metadata.name': 'opentelemetry-collector',
      },
    },
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/component': 'opentelemetry-collector',
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
  grafana: {
    namespaceSelector: {
      matchLabels: {
        'kubernetes.io/metadata.name': 'monitoring',
      },
    },
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/instance': 'grafana',
        'app.kubernetes.io/name': 'grafana',
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
