CREATE KEYSPACE IF NOT EXISTS walnuk
    WITH replication = {'class': 'NetworkTopologyStrategy', 'iwakura': '3'}
    AND tablets = {'enabled': false};
CREATE ROLE IF NOT EXISTS 'walnuk'
    WITH PASSWORD = '{{ .walnuk_password }}'
    AND SUPERUSER = false
    AND LOGIN = true;
GRANT ALL PERMISSIONS ON KEYSPACE walnuk TO 'walnuk';


CREATE KEYSPACE IF NOT EXISTS picca
    WITH replication = {'class': 'NetworkTopologyStrategy', 'iwakura': '3'}
    AND tablets = {'enabled': false};
CREATE ROLE IF NOT EXISTS 'picca'
    WITH PASSWORD = '{{ .picca_password }}'
    AND SUPERUSER = false
    AND LOGIN = true;
GRANT ALL PERMISSIONS ON KEYSPACE picca TO 'picca';

CREATE TABLE IF NOT EXISTS picca.stack_timeline_watermark_by_owner (
    owner_id uuid PRIMARY KEY,
    applied_revision bigint
);

CREATE KEYSPACE IF NOT EXISTS picca_dev
    WITH replication = {'class': 'NetworkTopologyStrategy', 'iwakura': '3'}
    AND tablets = {'enabled': false};
CREATE ROLE IF NOT EXISTS 'picca_dev'
    WITH PASSWORD = '{{ .picca_dev_password }}'
    AND SUPERUSER = false
    AND LOGIN = true;
GRANT ALL PERMISSIONS ON KEYSPACE picca_dev TO 'picca_dev';
CREATE TABLE IF NOT EXISTS picca_dev.stack_timeline_watermark_by_owner (
    owner_id uuid PRIMARY KEY,
    applied_revision bigint
);

CREATE KEYSPACE IF NOT EXISTS prfexample
    WITH replication = {'class': 'NetworkTopologyStrategy', 'iwakura': '3'}
    AND tablets = {'enabled': false};
CREATE ROLE IF NOT EXISTS 'prfexample'
    WITH PASSWORD = '{{ .prfexample_password }}'
    AND SUPERUSER = false
    AND LOGIN = true;
GRANT ALL PERMISSIONS ON KEYSPACE prfexample TO 'prfexample';
CREATE TABLE IF NOT EXISTS prfexample.stack_timeline_watermark_by_owner (
    owner_id uuid PRIMARY KEY,
    applied_revision bigint
);
