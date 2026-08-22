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
CREATE TABLE IF NOT EXISTS seaweedfs.filemeta (
    dirhash bigint,
    directory varchar,
    name varchar,
    meta blob,
PRIMARY KEY ((dirhash, directory), name)
) WITH CLUSTERING ORDER BY (name ASC);

CREATE KEYSPACE IF NOT EXISTS picca
    WITH replication = {'class': 'NetworkTopologyStrategy', 'iwakura': '3'}
    AND tablets = {'enabled': false};
CREATE ROLE IF NOT EXISTS 'picca'
    WITH PASSWORD = '{{ .picca_password }}'
    AND SUPERUSER = false
    AND LOGIN = true;
GRANT ALL PERMISSIONS ON KEYSPACE picca TO 'picca';
CREATE TABLE IF NOT EXISTS picca.timeline_by_owner (
    owner_id uuid,
    captured_day date,
    captured_at timestamp,
    media_id uuid,
    file_name text,
    mime_type text,
    width int,
    height int,
    thumbnail_key text,
    blur_hash text,
    thumbnail_status text,
    processing_status text,
    projection_revision bigint,
    PRIMARY KEY ((owner_id, captured_day), captured_at, media_id)
) WITH CLUSTERING ORDER BY (captured_at DESC);
ALTER TABLE picca.timeline_by_owner ADD IF NOT EXISTS projection_revision bigint;

CREATE KEYSPACE IF NOT EXISTS prfexample
    WITH replication = {'class': 'NetworkTopologyStrategy', 'iwakura': '3'}
    AND tablets = {'enabled': false};
CREATE ROLE IF NOT EXISTS 'prfexample'
    WITH PASSWORD = '{{ .prfexample_password }}'
    AND SUPERUSER = false
    AND LOGIN = true;
GRANT ALL PERMISSIONS ON KEYSPACE prfexample TO 'prfexample';
