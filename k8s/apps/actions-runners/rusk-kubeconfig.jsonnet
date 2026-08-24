local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';

externalSecret {
  name: 'rusk-kubeconfig',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'kubeconfig',
      remoteRef: {
        key: 'sharc-rusk',
        property: 'kubeconfig',
      },
    },
  ],
  template_data: {
    kubeconfig: '{{ .kubeconfig }}',
  },
}
