local gen = function(database) {
  apiVersion: 'postgresql.cnpg.io/v1',
  kind: 'Database',
  metadata: {
    name: std.strReplace(database.db_name, '_', '-'),
  },
  spec: {
    name: database.db_name,
    owner: database.user_name,
    cluster: {
      name: (import 'postgres.jsonnet').metadata.name,
    },
    // localeCollate: 'ja_JP.UTF-8',
    // localeCType: 'ja_JP.UTF-8',
  } + (if 'extensions' in database then { extensions: database.extensions } else {}),
};
std.map(gen, (import 'databases.libsonnet'))
