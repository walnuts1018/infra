#!/bin/sh
set -eu

app_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$app_dir/../../.." && pwd)
config_dir="$app_dir/.local"
plan_file="$config_dir/stalwart-plan.ndjson"

if [ "${1:-}" = "--dry-run" ]; then
  dry_run=true
elif [ "$#" -eq 0 ]; then
  dry_run=false
else
  echo "usage: $0 [--dry-run]" >&2
  exit 64
fi

umask 077
mkdir -p "$config_dir"

ses_username=$(terraform -chdir="$repo_dir/terraform" output -raw stalwart_ses_smtp_username)
ses_password=$(terraform -chdir="$repo_dir/terraform" output -raw stalwart_ses_smtp_password)
zitadel_client_id=$(terraform -chdir="$repo_dir/terraform" output -raw stalwart_oidc_client_id)
elasticsearch_password=$(kubectl get secret -n stalwart stalwart-es-elastic-user -o jsonpath='{.data.elastic}' | base64 -d)

jq -cn \
  --arg ses_username "$ses_username" \
  --arg ses_password "$ses_password" \
  --arg zitadel_client_id "$zitadel_client_id" \
  --arg elasticsearch_password "$elasticsearch_password" \
  '
  [
    {
      "@type": "upsert",
      object: "Directory",
      matchOn: ["description"],
      value: {
        zitadel: {
          "@type": "Oidc",
          description: "ZITADEL",
          issuerUrl: "https://auth.walnuts.dev",
          requireAudience: $zitadel_client_id,
          claimUsername: "preferred_username",
          claimName: "name"
        }
      }
    },
    {
      "@type": "update",
      object: "Authentication",
      value: {directoryId: "#zitadel"}
    },
    {
      "@type": "update",
      object: "BlobStore",
      value: {
        "@type": "S3",
        region: {
          "@type": "Custom",
          customEndpoint: "https://seaweedfs.local.walnuts.dev",
          customRegion: "us-east-1"
        },
        bucket: "stalwart",
        secretKey: {"@type": "None"},
        securityToken: {"@type": "None"},
        sessionToken: {"@type": "None"},
        timeout: "30s",
        maxRetries: 3,
        allowInvalidCerts: false,
        verifyAfterWrite: true
      }
    },
    {
      "@type": "update",
      object: "InMemoryStore",
      value: {
        "@type": "Redis",
        url: "redis://valkey-stalwart-valkey.stalwart.svc.cluster.local:6379",
        timeout: "15s",
        poolMaxConnections: 16
      }
    },
    {
      "@type": "update",
      object: "SearchStore",
      value: {
        "@type": "ElasticSearch",
        url: "https://stalwart-es-http.stalwart.svc.cluster.local:9200",
        httpAuth: {
          "@type": "Basic",
          username: "elastic",
          secret: {"@type": "Value", secret: $elasticsearch_password}
        },
        httpHeaders: {},
        timeout: "30s",
        allowInvalidCerts: true,
        numShards: 1,
        numReplicas: 0,
        includeSource: false
      }
    },
    {
      "@type": "update",
      object: "Metrics",
      value: {
        openTelemetry: {
          "@type": "Grpc",
          endpoint: "http://default-collector.opentelemetry-collector.svc.cluster.local:4317",
          interval: "1m",
          timeout: "10s"
        }
      }
    },
    {
      "@type": "upsert",
      object: "MtaRoute",
      matchOn: ["name"],
      value: {
        ses: {
          "@type": "Relay",
          name: "ses",
          description: "Amazon SES SMTP relay",
          address: "email-smtp.ap-northeast-1.amazonaws.com",
          port: 587,
          protocol: "smtp",
          implicitTls: false,
          allowInvalidCerts: false,
          authUsername: $ses_username,
          authSecret: {"@type": "Value", secret: $ses_password}
        }
      }
    },
    {
      "@type": "update",
      object: "MtaOutboundStrategy",
      value: {
        route: {
          match: [{if: "is_local_domain(rcpt_domain)", then: "'local'"}],
          else: "'ses'"
        }
      }
    }
  ] | .[]
  ' > "$plan_file"

if [ "$dry_run" = true ]; then
  STALWART_URL=https://stalwart.local.walnuts.dev \
  STALWART_USER=admin \
  STALWART_PASSWORD=YourNewPassword123 \
  stalwart-cli apply --file "$plan_file" --dry-run
else
  STALWART_URL=https://stalwart.local.walnuts.dev \
  STALWART_USER=admin \
  STALWART_PASSWORD=YourNewPassword123 \
  stalwart-cli apply --file "$plan_file"
fi
