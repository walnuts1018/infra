#!/usr/bin/bash

/aws-cli/aws sts assume-role-with-web-identity \
  --role-arn arn:aws:iam::dummy:role/terrakube \
  --role-session-name "terrakube-session-$(date +%s)" \
  --profile assume-role
  --duration-seconds 86400 \
  --web-identity-token file:///var/run/secrets/sts.min.io/serviceaccount/token \
  --endpoint-url https://sts-minio.local.walnuts.dev/sts/minio \
  --region ap-northeast-1 | \
  jq '{
    Version: 1,
    AccessKeyId: .Credentials.AccessKeyId,
    SecretAccessKey: .Credentials.SecretAccessKey,
    SessionToken: .Credentials.SessionToken,
    Expiration: .Credentials.Expiration
  }'
