#!/usr/bin/env bash
set -euo pipefail

mkdir -p /data/config
node dist/server &
server_pid=$!
trap 'kill "$server_pid" 2>/dev/null || true' EXIT

until curl --fail --silent http://127.0.0.1:9000/api/v1/ping >/dev/null; do
  if ! kill -0 "$server_pid" 2>/dev/null; then
    wait "$server_pid"
  fi
  sleep 2
done

if [[ ! -f /data/config/oidc-plugin-installed ]]; then
  if [[ ! -f /data/config/oidc-configured ]]; then
    node dist/scripts/migrations/peertube-8.3.js
    npm run plugin:install -- --npm-name peertube-plugin-auth-openid-connect@2.1.0
  fi
  touch /data/config/oidc-plugin-installed
fi

configured=0
for _ in {1..30}; do
  if node <<'NODE'
(async () => {
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

  const request = async (path, options = {}) => {
    const response = await fetch(`http://127.0.0.1:9000${path}`, options)
    if (!response.ok) {
      throw new Error(`${options.method ?? 'GET'} ${path}: ${response.status}`)
    }
    return response
  }

  const oauthClient = await request('/api/v1/oauth-clients/local')
    .then(response => response.json())
  const session = await request('/api/v1/users/token', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_id: oauthClient.client_id,
      client_secret: oauthClient.client_secret,
      grant_type: 'password',
      response_type: 'code',
      username: 'root',
      password: process.env.PT_INITIAL_ROOT_PASSWORD,
    }),
  }).then(response => response.json())

  await request('/api/v1/plugins/peertube-plugin-auth-openid-connect/settings', {
    method: 'PUT',
    headers: {
      authorization: `Bearer ${session.access_token}`,
      'content-type': 'application/json',
    },
    body: JSON.stringify({ settings }),
  })
})().catch(error => {
  console.error(error)
  process.exit(1)
})
NODE
  then
    configured=1
    break
  fi
  sleep 2
done

if [[ "${configured}" -ne 1 ]]; then
  echo 'failed to reconcile PeerTube OIDC plugin settings' >&2
  exit 1
fi

kill "$server_pid"
wait "$server_pid" || true
trap - EXIT

exec node dist/server
