local gen = function(namespace) {
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: namespace,
    [if namespace == 'coder-workspaces' then 'labels']: {
      'pod-security.kubernetes.io/enforce': 'privileged',
      'pod-security.kubernetes.io/audit': 'restricted',
      'pod-security.kubernetes.io/warn': 'restricted',
    },
  },
};

std.map(gen, import 'namespaces.json5')
