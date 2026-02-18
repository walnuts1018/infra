local namespaces = (import 'namespaces.json5');

local gen = function(namespace) {
  local name = if std.isString(namespace) then namespace else namespace.name,
  local labels = if std.isObject(namespace) && std.objectHas(namespace, 'labels') then namespace.labels else null,

  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
              name: name,
            } +
            (if labels != null then { labels: labels } else {}),
};

std.map(gen, namespaces)
