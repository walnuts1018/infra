(import '../../components/configmap.libsonnet') {
  name: 'aws-config',
  namespace: (import 'app.json5').namespace,
  use_suffix: false,
  data: {
    config: (importstr './_config/aws-config'),
    'assumerole.sh': (importstr './_scripts/assumerole.sh'),
  },
}
