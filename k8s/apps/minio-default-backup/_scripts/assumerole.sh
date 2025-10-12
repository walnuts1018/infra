#!/usr/bin/bash

aws sts assume-role-with-web-identity \
  --role-arn arn:aws:iam::dummy:role/minio-default-backup \
  --role-session-name "minio-default-backup-session-$(date +%s)" \
  --web-identity-token file:///var/run/secrets/sts.min.io/serviceaccount/token \
  --endpoint-url https://sts.minio-operator.svc.cluster.local:4223/sts/minio \
  --ca-bundle /etc/ssl/certs/trust-bundle.pem \
  --region ap-northeast-1
