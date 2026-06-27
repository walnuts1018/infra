local gen = function(namespace) {
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: namespace,
  },
};

std.map(gen, import 'namespaces.json5')
