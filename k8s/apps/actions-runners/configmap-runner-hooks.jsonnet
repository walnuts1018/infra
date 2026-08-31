local app = import 'app.json5';

(import '../../components/configmap.libsonnet') {
  name: 'runner-hooks',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name),
  data: {
    'job-started.sh': importstr './_scripts/job-started.sh',
    'job-completed.sh': importstr './_scripts/job-completed.sh',
  },
}
