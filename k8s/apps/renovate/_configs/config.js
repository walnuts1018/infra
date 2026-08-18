const crypto = require("crypto");

function base64urlJson(value) {
  return Buffer.from(JSON.stringify(value)).toString("base64url");
}

async function createInstallationToken() {
  const appId = process.env.GITHUB_APP_ID;
  const installationId = process.env.GITHUB_APP_INSTALLATION_ID;
  const privateKey = process.env.GITHUB_APP_PRIVATE_KEY?.replace(/\\n/g, "\n");

  if (!appId) {
    throw new Error("GITHUB_APP_ID is required");
  }

  if (!installationId) {
    throw new Error("GITHUB_APP_INSTALLATION_ID is required");
  }

  if (!privateKey) {
    throw new Error("GITHUB_APP_PRIVATE_KEY is required");
  }

  const now = Math.floor(Date.now() / 1000);

  const header = base64urlJson({
    alg: "RS256",
    typ: "JWT",
  });

  const payload = base64urlJson({
    iat: now - 60,
    exp: now + 600,
    iss: appId,
  });

  const unsignedJwt = `${header}.${payload}`;

  const signature = crypto.createSign("RSA-SHA256").update(unsignedJwt).sign(privateKey, "base64url");

  const jwt = `${unsignedJwt}.${signature}`;

  const response = await fetch(`https://api.github.com/app/installations/${installationId}/access_tokens`, {
    method: "POST",
    headers: {
      Accept: "application/vnd.github+json",
      Authorization: `Bearer ${jwt}`,
      "X-GitHub-Api-Version": "2026-03-10",
      "User-Agent": "self-hosted-renovate",
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to create GitHub App installation token: ${response.status} ${await response.text()}`);
  }

  const data = await response.json();

  if (!data.token) {
    throw new Error("GitHub App installation token response did not include a token");
  }

  return data.token;
}

module.exports = async () => {
  const token = await createInstallationToken();

  const ghcrToken = process.env.GHCR_TOKEN;

  if (!ghcrToken) {
    throw new Error("GHCR_TOKEN is required");
  }

  return {
    token,

    hostRules: [
      {
        hostType: "docker",
        matchHost: "https://ghcr.io",
        username: "walnuts1018",
        password: ghcrToken,
      },
    ],
  };
};
