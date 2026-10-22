local baseLabels = {
  'pod-security.kubernetes.io/audit': 'restricted',
  'pod-security.kubernetes.io/audit-version': 'v1.36',
  'pod-security.kubernetes.io/warn': 'restricted',
  'pod-security.kubernetes.io/warn-version': 'v1.36',
};

local gen = function(namespace)
  local labels = if namespace == 'coder-workspaces' then
    baseLabels { 'pod-security.kubernetes.io/enforce': 'privileged' }
  else
    baseLabels;

  local ghcrLabels = if std.member(['beast', 'iwashi-system', 'picca'], namespace) then
    { 'walnuts.dev/ghcr-login-secret': 'true' }
  else
    {};

  {
    apiVersion: 'v1',
    kind: 'Namespace',
    metadata: {
      name: namespace,
      labels: labels + ghcrLabels,
    },
  };

std.map(gen, import 'namespaces.json5')
