local namespaces = import 'namespaces.json5';
local namespaces = (namespaces);

local gen = function(namespace) {
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: namespace,
  },
};

std.map(gen, namespaces)
