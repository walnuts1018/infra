local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name + '-s3',
    namespace: app.namespace,
    labels: (labels)(app.name + '-s3'),
  },
  spec: {
    parentRefs: [
      {
        name: gateway.metadata.name,
        namespace: gateway.metadata.namespace,
      },
    ],
    // ワイルドカード hostname を external-dns (coredns provider) が実際に
    // ワイルドカード DNS レコードとして登録するか未検証のため、バケットごとに
    // 具体的な hostname を列挙する。バケットを追加したらここにも追記する。
    hostnames: [
      'visual-regression-tracker.seaweedfs.local.walnuts.dev',
    ],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: app.name + '-filer',
            port: 8333,
          },
        ],
      },
    ],
  },
}
