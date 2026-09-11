local base = std.parseYaml(importstr '../../../apps/cilium/values.yaml');
local biscuit = std.parseYaml(importstr '../../../apps/cilium/values.biscuit.yaml');

function(clusterName)
  if clusterName == 'biscuit' then std.mergePatch(base, biscuit) else base
