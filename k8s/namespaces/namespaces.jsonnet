local baseLabels = {
  'pod-security.kubernetes.io/audit': 'restricted',
  'pod-security.kubernetes.io/audit-version': 'v1.36',
  'pod-security.kubernetes.io/warn': 'restricted',
  'pod-security.kubernetes.io/warn-version': 'v1.36',
};

local gen = function(namespace) {
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: namespace,
    labels: if namespace == 'coder-workspaces' then
      baseLabels { 'pod-security.kubernetes.io/enforce': 'privileged' }
    else
      baseLabels,
  },
};

std.map(gen, import 'namespaces.json5')
