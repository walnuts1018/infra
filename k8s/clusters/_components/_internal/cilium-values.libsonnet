local base = std.parseYaml(importstr '../../../apps/cilium/values.yaml');
local clusterValues = {
  biscuit: std.parseYaml(importstr '../../../apps/cilium/values.biscuit.yaml'),
  kurumi: std.parseYaml(importstr '../../../apps/cilium/values.kurumi.yaml'),
};

function(clusterName)
  std.mergePatch(base, clusterValues[clusterName])
