local gen = function(namespace) {
  local name = if std.isString(namespace) then namespace else namespace.name,
  local labels = if std.isObject(namespace) && std.objectHas(namespace, 'labels') then namespace.labels else null,

  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: name,
    annotations: {
      // Namespace pruning removes every namespaced resource below it.
      'argocd.argoproj.io/sync-options': 'Prune=confirm',
    },
  } + (if labels != null then { labels: labels } else {}),
};

function(namespaces) std.map(gen, namespaces)
