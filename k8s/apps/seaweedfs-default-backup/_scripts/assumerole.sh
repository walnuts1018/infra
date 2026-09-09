#!/usr/bin/bash

aws sts assume-role-with-web-identity \
  --role-arn arn:aws:iam::role/seaweedfs-default-backup \
  --role-session-name "seaweedfs-default-backup-session-$(date +%s)" \
  --duration-seconds 86400 \
  --web-identity-token file:///var/run/secrets/sts.seaweedfs.com/serviceaccount/token \
  --endpoint-url http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333 \
  --region us-east-1 | \
  jq '{
    Version: 1,
    AccessKeyId: .Credentials.AccessKeyId,
    SecretAccessKey: .Credentials.SecretAccessKey,
    SessionToken: .Credentials.SessionToken,
    Expiration: .Credentials.Expiration
  }'
