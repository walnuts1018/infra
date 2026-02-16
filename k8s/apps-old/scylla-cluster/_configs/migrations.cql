CREATE KEYSPACE IF NOT EXISTS walnuk
    WITH replication = {'class': 'NetworkTopologyStrategy', 'iwakura': '3'}
    AND tablets = {'enabled': false};
CREATE ROLE IF NOT EXISTS 'walnuk'
    WITH PASSWORD = '{{ .walnuk_password }}'
    AND SUPERUSER = false
    AND LOGIN = true;
GRANT ALL PERMISSIONS ON KEYSPACE walnuk TO 'walnuk';


CREATE KEYSPACE IF NOT EXISTS seaweedfs
    WITH replication = {'class': 'NetworkTopologyStrategy', 'iwakura': '3'}
    AND tablets = {'enabled': false};
CREATE ROLE IF NOT EXISTS 'seaweedfs'
    WITH PASSWORD = '{{ .seaweedfs_password }}'
    AND SUPERUSER = false
    AND LOGIN = true;
GRANT ALL PERMISSIONS ON KEYSPACE seaweedfs TO 'seaweedfs';
CREATE TABLE seaweedfs.filemeta (
    dirhash bigint,
    directory varchar,
    name varchar,
    meta blob,
PRIMARY KEY ((dirhash, directory), name)
) WITH CLUSTERING ORDER BY (name ASC);
