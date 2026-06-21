function(
  clusterName='kurumi',
)
  local base = (import '_base.libsonnet')(clusterName);
  std.mergePatch(base, {
    metadata: {
      name: 'vyos',
    },
    spec: {
      replicas: 1,
      mode: 'deployment',
      ports: [
        {
          name: 'syslog-udp',
          port: 5514,
          protocol: 'UDP',
        },
        {
          name: 'netflow-udp',
          port: 2055,
          protocol: 'UDP',
        },
      ],
      config: {
        receivers: {
          prometheus: {
            config: {
              scrape_configs: [
                {
                  job_name: 'vyos-telegraf',
                  scrape_interval: '30s',
                  static_configs: [
                    {
                      targets: [
                        '192.168.0.1:9273',
                      ],
                      labels: {
                        instance: 'vyos',
                        device: 'vyos',
                      },
                    },
                  ],
                },
              ],
            },
          },
          syslog: {
            udp: {
              listen_address: '0.0.0.0:5514',
              add_attributes: true,
              one_log_per_packet: true,
            },
            protocol: 'rfc3164',
            location: 'Asia/Tokyo',
            resource: {
              'service.name': 'vyos-syslog',
              'host.name': 'vyos',
              'host.ip': '192.168.0.1',
            },
          },
          netflow: {
            scheme: 'netflow',
            hostname: '0.0.0.0',
            port: 2055,
            sockets: 2,
            workers: 4,
          },
        },
        processors: {
          memory_limiter: {
            check_interval: '1s',
            limit_mib: 512,
            spike_limit_percentage: 15,
          },
          'resource/vyos': {
            attributes: [
              {
                key: 'service.name',
                action: 'upsert',
                value: 'vyos',
              },
              {
                key: 'host.name',
                action: 'upsert',
                value: 'vyos',
              },
              {
                key: 'host.ip',
                action: 'upsert',
                value: '192.168.0.1',
              },
            ],
          },
          'resource/netflow': {
            attributes: [
              {
                key: 'service.name',
                action: 'upsert',
                value: 'vyos-netflow',
              },
              {
                key: 'host.name',
                action: 'upsert',
                value: 'vyos',
              },
              {
                key: 'host.ip',
                action: 'upsert',
                value: '192.168.0.1',
              },
            ],
          },
        },
        service: {
          pipelines: {
            metrics: {
              receivers: [
                'prometheus',
              ],
              processors: [
                'memory_limiter',
                'resource/vyos',
                'resource/cluster_name',
              ],
              exporters: [
                'prometheusremotewrite/victoriametrics',
              ],
            },
            'logs/syslog': {
              receivers: [
                'syslog',
              ],
              processors: [
                'memory_limiter',
                'resource/cluster_name',
              ],
              exporters: [
                'otlp_http/loki',
              ],
            },
            'logs/netflow': {
              receivers: [
                'netflow',
              ],
              processors: [
                'memory_limiter',
                'resource/netflow',
                'resource/cluster_name',
              ],
              exporters: [
                'otlp_http/loki',
              ],
            },
          },
        },
      },
      resources: {
        requests: {
          cpu: '20m',
          memory: '128Mi',
        },
        limits: {
          cpu: '500m',
          memory: '1Gi',
        },
      },
    },
  })
