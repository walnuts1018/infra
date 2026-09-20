#!/usr/bin/env sh
set -eu

token_file='/runner-bootstrap/registration-token'
mkdir -p '/runner-bootstrap'

if [ -s "${token_file}" ]; then
  exit 0
fi

export TOKEN_FILE="${token_file}"
node <<'NODE'
const fs = require('node:fs/promises')

const baseURL = process.env.PEERTUBE_URL
const username = 'root'
const password = process.env.PEERTUBE_ROOT_PASSWORD

async function request(path, options = {}) {
  const response = await fetch(`${baseURL}${path}`, options)
  if (!response.ok) {
    throw new Error(`${options.method ?? 'GET'} ${path}: ${response.status}`)
  }
  return response
}

async function main() {
  const oauthClient = await request('/api/v1/oauth-clients/local').then(response => response.json())
  const body = new URLSearchParams({
    client_id: oauthClient.client_id,
    client_secret: oauthClient.client_secret,
    grant_type: 'password',
    response_type: 'code',
    username,
    password,
  })
  const session = await request('/api/v1/users/token', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body,
  }).then(response => response.json())
  const headers = { authorization: `Bearer ${session.access_token}` }
  let tokens = await request('/api/v1/runners/registration-tokens?count=100', { headers })
    .then(response => response.json())

  if (tokens.total === 0) {
    await request('/api/v1/runners/registration-tokens/generate', {
      method: 'POST',
      headers,
    })
    tokens = await request('/api/v1/runners/registration-tokens?count=100', { headers })
      .then(response => response.json())
  }

  const token = tokens.data
    .sort((left, right) => new Date(right.createdAt) - new Date(left.createdAt))[0]
    ?.registrationToken
  if (!token) throw new Error('PeerTube did not return a runner registration token')

  await fs.writeFile(process.env.TOKEN_FILE, `${token}\n`, { mode: 0o600 })
}

main().catch(error => {
  console.error(error)
  process.exit(1)
})
NODE
