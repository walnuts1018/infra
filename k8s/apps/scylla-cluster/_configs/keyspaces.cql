CREATE KEYSPACE IF NOT EXISTS walnuk
    WITH replication = {'class': 'NetworkTopologyStrategy', 'iwakura': '3'}
    AND tablets = {'enabled': false};

CREATE KEYSPACE IF NOT EXISTS seaweedfs
    WITH replication = {'class': 'NetworkTopologyStrategy', 'iwakura': '3'}
    AND tablets = {'enabled': false};
