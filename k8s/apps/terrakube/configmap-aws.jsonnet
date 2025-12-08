(import '../../components/configmap.libsonnet') {
  name: 'aws-config',
  namespace: (import 'app.json5').namespace,
  data: {
    config: (importstr './_config/aws-config'),
    'assumerole.sh': (importstr './_scripts/assumerole.sh'),
  },
}
