local desired = import '../apps/seaweedfs-default/_configs/desired-state.json';

function(identityName)
  std.filter(function(i) i.name == identityName, desired.accessKeyIdentities)[0].secretTarget
