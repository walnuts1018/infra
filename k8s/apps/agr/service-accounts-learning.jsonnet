local app = import 'app.json5';
[
  {
    apiVersion: 'v1',
    kind: 'ServiceAccount',
    metadata: {
      name: 'agr-' + stage,
      namespace: app.namespace,
    },
    automountServiceAccountToken: false,
  }
  for stage in [
    'planner',
    'actor',
    'dataset',
    'trainer',
    'validator',
    'evaluator',
    'promoter',
    'verify',
    'gc',
  ]
]
