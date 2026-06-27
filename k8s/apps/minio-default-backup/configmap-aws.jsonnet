local configmap = import '../../components/configmap.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local awsConfig = importstr './_config/aws-config';
(configmap) {
  name: app.name + '-aws',
  namespace: app.namespace,
  labels: (labels)(app.name),
  data: {
    config: (awsConfig),
  },
}
