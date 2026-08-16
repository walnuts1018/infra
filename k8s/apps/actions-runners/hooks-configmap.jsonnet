{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'runner-hooks',
    namespace: 'arc-runners',
  },
  data: {
    'job-started.sh': importstr '_scripts/job-started.sh',
    'job-completed.sh': importstr '_scripts/job-completed.sh',
  },
}
