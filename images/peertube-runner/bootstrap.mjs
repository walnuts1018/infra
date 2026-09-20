import http from 'node:http'
import { mkdir, readFile, writeFile } from 'node:fs/promises'
import { dirname } from 'node:path'

const baseURL = process.env.PEERTUBE_URL
const host = process.env.PEERTUBE_HOST
const password = process.env.PEERTUBE_ROOT_PASSWORD
const runnerID = process.env.RUNNER_ID ?? 'vod'
const runnerName = process.env.RUNNER_NAME ?? `peertube-runner-${runnerID}`
const staticConfigFile = process.env.RUNNER_STATIC_CONFIG_FILE ?? '/bootstrap/config.toml'
const configHome = process.env.XDG_CONFIG_HOME ?? '/home/peertube/.config'
const configFile = `${configHome}/peertube-runner-nodejs/${runnerID}/config.toml`

if (!baseURL || !host || !password) {
  throw new Error('PEERTUBE_URL, PEERTUBE_HOST, and PEERTUBE_ROOT_PASSWORD are required')
}

async function request(path, options = {}) {
  const url = new URL(path, baseURL)
  const body = options.body instanceof URLSearchParams
    ? options.body.toString()
    : options.body
  const headers = {
    ...(options.headers ?? {}),
    host,
  }

  return new Promise((resolve, reject) => {
    const req = http.request(url, {
      method: options.method ?? 'GET',
      headers,
    }, response => {
      const chunks = []

      response.on('data', chunk => chunks.push(chunk))
      response.on('end', () => {
        const text = Buffer.concat(chunks).toString('utf8')
        const status = response.statusCode ?? 0

        if (status < 200 || status >= 300) {
          reject(new Error(`${options.method ?? 'GET'} ${path}: ${status} ${text}`))
          return
        }

        resolve({
          json: async () => JSON.parse(text),
          text: async () => text,
        })
      })
    })

    req.on('error', reject)

    if (body !== undefined) req.write(body)

    req.end()
  })
}

function tomlString(value) {
  return JSON.stringify(value)
}

function registrationFromConfig(config) {
  const runnerToken = config.match(/^runnerToken\s*=\s*"([^"]+)"/m)?.[1]
  if (!runnerToken) return null

  return {
    url: config.match(/^url\s*=\s*"([^"]+)"/m)?.[1] ?? baseURL,
    runnerToken,
    runnerName: config.match(/^runnerName\s*=\s*"([^"]+)"/m)?.[1] ?? runnerName,
  }
}

async function login() {
  const oauthClient = await request('/api/v1/oauth-clients/local').then(response => response.json())
  const body = new URLSearchParams({
    client_id: oauthClient.client_id,
    client_secret: oauthClient.client_secret,
    grant_type: 'password',
    response_type: 'code',
    username: 'root',
    password,
  })

  return request('/api/v1/users/token', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body,
  }).then(response => response.json())
}

async function getRegistrationToken(headers) {
  const tokens = await request('/api/v1/runners/registration-tokens?count=1', { headers })
    .then(response => response.json())

  const token = tokens.data?.[0]?.registrationToken
  if (!token) throw new Error('PeerTube did not return a runner registration token')
  return token
}

async function registerRunner(registrationToken) {
  const result = await request('/api/v1/runners/register', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({
      name: runnerName,
      registrationToken,
    }),
  }).then(response => response.json())

  if (!result.runnerToken) throw new Error('PeerTube did not return a runner token')
  return {
    url: baseURL,
    runnerToken: result.runnerToken,
    runnerName,
  }
}

async function main() {
  let previousConfig = ''
  try {
    previousConfig = await readFile(configFile, 'utf8')
  } catch (error) {
    if (error.code !== 'ENOENT') throw error
  }

  let registration = registrationFromConfig(previousConfig)
  if (!registration) {
    const session = await login()
    const headers = { authorization: `Bearer ${session.access_token}` }
    const registrationToken = await getRegistrationToken(headers)
    registration = await registerRunner(registrationToken)
  }

  const staticConfig = await readFile(staticConfigFile, 'utf8')
  const config = `${staticConfig.trimEnd()}\n\n[[registeredInstances]]\n` +
    `url = ${tomlString(registration.url)}\n` +
    `runnerToken = ${tomlString(registration.runnerToken)}\n` +
    `runnerName = ${tomlString(registration.runnerName)}\n`

  await mkdir(dirname(configFile), { recursive: true })
  await writeFile(configFile, config, { mode: 0o600 })
}

main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
