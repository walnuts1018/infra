local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: app.name + '-kubeconfig',
    namespace: app.namespace,
  },
  data: {
    config: |||
      apiVersion: v1
      kind: Config
      clusters:
      - name: main
        cluster:
          server: https://kube-oidc-proxy.kube-oidc-proxy.svc:443
          certificate-authority: /etc/kube-oidc-proxy/trust-bundle.pem
      contexts:
      - name: main
        context:
          cluster: main
          user: oidc
      current-context: main
      users:
      - name: oidc
        user:
          auth-provider:
            name: oidc
    |||,
  },
}
