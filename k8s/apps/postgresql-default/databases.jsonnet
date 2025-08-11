local databases = (import 'databases.libsonnet');
local gen = function(database) {
  apiVersion: 'postgresql.cnpg.io/v1',
  kind: 'Database',
  metadata: {
    name: database.db_name,
  },
  spec: {
    name: database.db_name,
    owner: database.user_name,
    cluster: {
      name: (import 'postgres.jsonnet').metadata.name,
    },
  },
};

std.map(gen, databases)
