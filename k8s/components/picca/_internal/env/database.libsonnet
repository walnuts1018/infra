function(app)
  local dbName = std.strReplace(app.name, '-', '_');
  [
    {
      name: 'SCYLLA_HOSTS',
      value: 'scylla-cluster-client.databases.svc.cluster.local:9142',
    },
    {
      name: 'SCYLLA_DATACENTER',
      value: 'iwakura',
    },
    {
      name: 'SCYLLA_USER',
      value: dbName,
    },
  ]
