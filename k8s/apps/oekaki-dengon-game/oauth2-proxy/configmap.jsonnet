local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local robots = importstr './_config/robots.txt';
(import '../../../components/configmap.libsonnet') {
  name: app.name + '-oauth2-proxy',
  namespace: app.namespace,
  labels: (labels)(app.name),
  data: {
    'robots.txt': (robots),
  },
}
