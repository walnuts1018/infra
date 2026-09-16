local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: { name: app.name + '-migrations', namespace: app.namespace },
  data: {
    'migrate.sh': |||
      set -eu
      psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
      CREATE TABLE IF NOT EXISTS schema_migrations (name text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now());
      DO $migration$
      BEGIN
        IF NOT EXISTS (SELECT 1 FROM schema_migrations WHERE name = '001_initial.sql') THEN
          CREATE TABLE users (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(), external_id text NOT NULL UNIQUE,
            created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
          );
          CREATE TABLE organizations (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(), name text NOT NULL,
            vm_account_id integer NOT NULL UNIQUE CHECK (vm_account_id >= 0),
            vm_project_id integer NOT NULL CHECK (vm_project_id >= 0),
            created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
            UNIQUE (vm_account_id, vm_project_id)
          );
          CREATE TABLE organization_members (
            organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
            user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            role text NOT NULL CHECK (role IN ('owner', 'admin', 'member')),
            created_at timestamptz NOT NULL DEFAULT now(), PRIMARY KEY (organization_id, user_id)
          );
          CREATE TABLE monitors (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(), organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
            name text NOT NULL CHECK (length(name) BETWEEN 1 AND 200), url text NOT NULL,
            probe_type text NOT NULL DEFAULT 'http' CHECK (probe_type IN ('http')),
            interval_seconds integer NOT NULL CHECK (interval_seconds BETWEEN 15 AND 86400),
            timeout_seconds integer NOT NULL CHECK (timeout_seconds BETWEEN 1 AND interval_seconds),
            expected_status integer NOT NULL CHECK (expected_status BETWEEN 100 AND 599), enabled boolean NOT NULL DEFAULT true,
            created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
          );
          CREATE INDEX monitors_organization_id_idx ON monitors (organization_id, id);
          CREATE TABLE alert_rules (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(), organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
            monitor_id uuid NOT NULL REFERENCES monitors(id) ON DELETE CASCADE,
            kind text NOT NULL CHECK (kind IN ('endpoint_down', 'high_latency', 'unexpected_status')),
            threshold double precision, for_seconds integer NOT NULL CHECK (for_seconds >= 0), enabled boolean NOT NULL DEFAULT true,
            created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), UNIQUE (monitor_id, kind)
          );
          CREATE TABLE notification_settings (
            organization_id uuid PRIMARY KEY REFERENCES organizations(id) ON DELETE CASCADE,
            email_addresses text[] NOT NULL DEFAULT '{}', enabled boolean NOT NULL DEFAULT false,
            updated_at timestamptz NOT NULL DEFAULT now()
          );
          INSERT INTO schema_migrations (name) VALUES ('001_initial.sql');
        END IF;
        IF NOT EXISTS (SELECT 1 FROM schema_migrations WHERE name = '002_vm_account_sequence.sql') THEN
          CREATE SEQUENCE vm_account_id_seq AS integer MINVALUE 1000 START 1000;
          INSERT INTO schema_migrations (name) VALUES ('002_vm_account_sequence.sql');
        END IF;
      END
      $migration$;
      SQL
    |||,
  },
}
