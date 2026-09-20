#!/usr/bin/env bash
set -euo pipefail

mkdir -p /data/config
if [[ ! -f /data/config/oidc-configured ]]; then
  node dist/server &
  server_pid=$!
  trap 'kill "$server_pid" 2>/dev/null || true' EXIT

  until curl --fail --silent http://127.0.0.1:9000/api/v1/ping >/dev/null; do
    if ! kill -0 "$server_pid" 2>/dev/null; then
      wait "$server_pid"
    fi
    sleep 2
  done

  node dist/scripts/migrations/peertube-8.3.js
  npm run plugin:install -- --npm-name peertube-plugin-auth-openid-connect@2.1.0

  node <<'NODE'
(async () => {
  const { Client } = require('pg')

  const settings = {
    'auth-display-name': 'Zitadel',
    'discover-url': 'https://auth.walnuts.dev/.well-known/openid-configuration',
    'client-id': process.env.OIDC_CLIENT_ID,
    'client-secret': process.env.OIDC_CLIENT_SECRET,
    'scope': 'openid email profile offline_access urn:zitadel:iam:org:projects:roles',
    'username-property': 'preferred_username',
    'mail-property': 'email',
    'logout-redirect-uri': 'post_logout_redirect_uri=https://peertube.walnuts.dev/',
    'display-name-property': 'name',
    'role-property': '',
    'group-property': process.env.OIDC_ROLE_CLAIM_PROPERTY,
    'allowed-group': process.env.OIDC_ROLE_CLAIM,
    'signature-algorithm': 'RS256',
    'external-id-property': 'sub',
    'sanitize-username': true,
    'revalidate-refresh-with-idp': true,
  }

  const client = new Client({
    host: 'postgresql-default-rw.databases.svc.cluster.local',
    port: 5432,
    database: 'peertube',
    user: process.env.PEERTUBE_DB_USERNAME,
    password: process.env.PEERTUBE_DB_PASSWORD,
  })

  await client.connect()
  for (;;) {
    try {
      const result = await client.query(
        'UPDATE "plugin" SET "settings" = $1::jsonb WHERE "name" = $2 AND "type" = 1',
        [JSON.stringify(settings), 'peertube-plugin-auth-openid-connect'],
      )
      if (result.rowCount === 1) break
    } catch {}
    await new Promise(resolve => setTimeout(resolve, 2000))
  }
  await client.end()
})().catch(error => {
  console.error(error)
  process.exit(1)
})
NODE

  touch /data/config/oidc-configured
  kill "$server_pid"
  wait "$server_pid" || true
  trap - EXIT
fi

exec node dist/server
